import uuid
from datetime import date

from fastapi import HTTPException, status
from sqlalchemy import and_, case, func, or_
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import ApprovalStatus, NotificationType, TaskStatus, UserRole, WorkLogStatus
from app.models.project import Project, ProjectMember
from app.models.task import Task, TaskDependency
from app.models.user import User
from app.models.worklog import WorkLog
from app.schemas.task import TaskCreate, TaskUpdate
from app.services.audit import log_event
from app.services.dashboard import get_visible_project_ids
from app.services.notifications import create_notification
from app.services.projects import assert_can_manage_project, assert_can_view_project, get_project
from app.services.task_activity import log_task_activity


class TaskRepository(TenantScopedRepository[Task]):
    model = Task


def _can_manage_project_tasks(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID) -> None:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)


def _attach_computed_fields(db: Session, org_id: uuid.UUID, tasks: list[Task]) -> list[Task]:
    """Attaches fields that are never stored on the row itself, as plain
    instance attributes picked up by TaskOut's from_attributes (same pattern
    as UserOut.has_password): actual_hours (summed from approved WorkLog
    minutes) and created_by_full_name (batch-looked-up so the UI can show
    who defined each task without a separate users round-trip)."""
    if not tasks:
        return tasks
    task_ids = [t.id for t in tasks]
    rows = (
        db.query(
            WorkLog.task_id,
            func.sum(case((WorkLog.status == WorkLogStatus.approved, WorkLog.time_spent_minutes), else_=0)),
            func.sum(case((WorkLog.status == WorkLogStatus.submitted, WorkLog.time_spent_minutes), else_=0)),
            func.sum(
                case(
                    (WorkLog.status.in_([WorkLogStatus.approved, WorkLogStatus.submitted]), WorkLog.time_spent_minutes),
                    else_=0,
                )
            ),
        )
        .filter(
            WorkLog.organization_id == org_id,
            WorkLog.task_id.in_(task_ids),
        )
        .group_by(WorkLog.task_id)
        .all()
    )
    minutes_by_task = {task_id: (approved or 0, pending or 0, total or 0) for task_id, approved, pending, total in rows}

    creator_ids = {t.created_by_id for t in tasks}
    name_by_creator = dict(db.query(User.id, User.full_name).filter(User.id.in_(creator_ids)).all())

    for task in tasks:
        approved, pending, total = minutes_by_task.get(task.id, (0, 0, 0))
        task.actual_hours = round(approved / 60, 2)
        task.pending_hours = round(pending / 60, 2)
        task.total_logged_hours = round(total / 60, 2)
        task.created_by_full_name = name_by_creator.get(task.created_by_id)
    return tasks


_ROLE_RANK = {UserRole.employee: 1, UserRole.project_manager: 2, UserRole.org_admin: 3}


def _validate_assignee(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID,
    assignee_id: uuid.UUID,
) -> User:
    assignee = db.get(User, assignee_id)
    if assignee is None or assignee.organization_id != org_id or not assignee.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignee not found in this organization")
    if assignee.id == current_user.id:
        return assignee
    if _ROLE_RANK.get(current_user.role, 0) <= _ROLE_RANK.get(assignee.role, 0):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only assign tasks to a lower organizational role",
        )
    _can_manage_project_tasks(db, org_id, current_user, project_id)
    return assignee


def _task_reviewer_ids(db: Session, org_id: uuid.UUID, task: Task) -> set[uuid.UUID]:
    if task.project_id is None:
        return set()
    project = db.query(Project).filter(Project.id == task.project_id, Project.organization_id == org_id).first()
    reviewer_ids: set[uuid.UUID] = set()
    if project and project.manager_id:
        reviewer_ids.add(project.manager_id)
    if not reviewer_ids:
        reviewer_ids.update(
            user_id
            for (user_id,) in (
                db.query(ProjectMember.user_id)
                .join(User, ProjectMember.user_id == User.id)
                .filter(
                    ProjectMember.project_id == task.project_id,
                    User.organization_id == org_id,
                    User.role == UserRole.project_manager,
                    User.is_active.is_(True),
                )
                .all()
            )
        )
    if not reviewer_ids:
        reviewer_ids.update(
            user_id
            for (user_id,) in db.query(User.id)
            .filter(User.organization_id == org_id, User.role == UserRole.org_admin, User.is_active.is_(True))
            .all()
        )
    return reviewer_ids


def create_task(db: Session, org_id: uuid.UUID, current_user: User, data: TaskCreate) -> Task:
    if data.project_id is None:
        # Personal task: no project, always self-assigned.
        if data.assignee_id is not None and data.assignee_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A personal task (no project) must be assigned to its creator",
            )
        assignee_id = current_user.id
    else:
        project = get_project(db, org_id, current_user, data.project_id)
        assert_can_view_project(db, project, current_user)
        # An omitted assignee means "a task I opened for myself". Every
        # project member can do this; assigning another person follows the
        # organization role hierarchy.
        assignee_id = data.assignee_id or current_user.id
        _validate_assignee(db, org_id, current_user, data.project_id, assignee_id)

    if data.parent_task_id is not None:
        parent = TaskRepository(db, org_id).get(data.parent_task_id)
        if parent is None or parent.project_id != data.project_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="parent_task_id must reference a task in the same project",
            )

    task = Task(
        organization_id=org_id,
        project_id=data.project_id,
        parent_task_id=data.parent_task_id,
        assignee_id=assignee_id,
        created_by_id=current_user.id,
        title=data.title,
        description=data.description,
        priority=data.priority,
        value=data.value,
        start_date=data.start_date,
        deadline=data.deadline,
        estimated_hours=data.estimated_hours,
    )
    db.add(task)
    db.flush()

    log_task_activity(db, org_id, task.id, current_user.id, "task.create", {"title": task.title})

    if task.assignee_id is not None and task.assignee_id != current_user.id:
        create_notification(
            db,
            org_id,
            task.assignee_id,
            NotificationType.task_created,
            {"task_id": str(task.id), "task_title": task.title, "project_id": str(task.project_id) if task.project_id else None},
        )

    db.commit()
    db.refresh(task)
    return _attach_computed_fields(db, org_id, [task])[0]


def list_tasks(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID | None = None,
    assignee_id: uuid.UUID | None = None,
    status_filter: str | None = None,
    approval_status_filter: str | None = None,
    overdue: bool | None = None,
    personal_only: bool | None = None,
) -> list[Task]:
    if personal_only:
        # Personal tasks have no project, so they're always scoped to their
        # own creator -- there is no "visibility" question to resolve here.
        query = db.query(Task).filter(
            Task.organization_id == org_id, Task.project_id.is_(None), Task.created_by_id == current_user.id
        )
    elif project_id is not None:
        project = get_project(db, org_id, current_user, project_id)
        assert_can_view_project(db, project, current_user)
        query = db.query(Task).filter(Task.organization_id == org_id, Task.project_id == project_id)
        # An employee only ever sees their own work on a project's board --
        # org_admin/project_manager still see everything (they need the
        # overview to assign work and review it). Membership alone used to
        # be enough to see every teammate's tasks, which is more than an
        # employee needs and more than they asked to see.
        if current_user.role == UserRole.employee:
            query = query.filter(Task.assignee_id == current_user.id)
    else:
        # No project given -- list across every project the user can see
        # (same visibility rule the dashboard/reports/search endpoints use),
        # plus the caller's own personal tasks, plus any task assigned to the
        # caller even in a project they aren't formally a member of -- being
        # assigned a task is itself a legitimate reason to see it, and a
        # manager assigning work shouldn't be blocked on remembering to also
        # add the assignee as a project member first.
        visible_project_ids = get_visible_project_ids(db, org_id, current_user)
        own_personal_tasks = and_(Task.project_id.is_(None), Task.created_by_id == current_user.id)
        own_assigned_tasks = Task.assignee_id == current_user.id
        clauses = [own_personal_tasks, own_assigned_tasks]
        if visible_project_ids:
            clauses.append(Task.project_id.in_(visible_project_ids))
        query = db.query(Task).filter(Task.organization_id == org_id, or_(*clauses))

    if assignee_id is not None:
        query = query.filter(Task.assignee_id == assignee_id)
    if status_filter is not None:
        query = query.filter(Task.status == status_filter)
    if approval_status_filter is not None:
        query = query.filter(Task.approval_status == approval_status_filter)
    if overdue:
        query = query.filter(
            Task.deadline < date.today(),
            Task.status.notin_([TaskStatus.completed, TaskStatus.archived]),
        )

    tasks = query.order_by(Task.created_at.desc()).all()
    return _attach_computed_fields(db, org_id, tasks)


def get_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> Task:
    task = TaskRepository(db, org_id).get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.project_id is None:
        if task.created_by_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This is a personal task")
    elif task.assignee_id != current_user.id:
        # Being the assignee is always enough to view a task, even without
        # formal project membership (see list_tasks for the matching rule).
        # An employee who *isn't* the assignee never gets in via membership
        # alone, matching list_tasks -- only org_admin/project_manager can.
        if current_user.role == UserRole.employee:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only view your own tasks")
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_view_project(db, project, current_user)
    return _attach_computed_fields(db, org_id, [task])[0]


# An assignee is an active owner of the task, so they can keep its working
# details accurate as well as update status/progress. Reassignment remains a
# manager-only operation and is deliberately not included here.
_EMPLOYEE_ALLOWED_FIELDS = {
    "status",
    "progress_percent",
    "title",
    "description",
    "priority",
    "value",
    "estimated_hours",
    "start_date",
    "deadline",
}
_SELF_CREATED_ALLOWED_FIELDS = {
    "status",
    "progress_percent",
    "title",
    "description",
    "priority",
    "value",
    "estimated_hours",
    "start_date",
    "deadline",
}

_ACTIVITY_TRACKED_FIELDS = {"status", "assignee_id", "priority", "value"}


def update_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, data: TaskUpdate) -> Task:
    task = get_task(db, org_id, current_user, task_id)
    changes = data.model_dump(exclude_unset=True)

    # Changing status is reserved for the task's own assignee, full stop --
    # not even the org_admin/project_manager who can otherwise manage every
    # other field on the task. This is stricter than (and checked ahead of)
    # the role-based rules below, which still govern every other field.
    if "status" in changes and task.assignee_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the task's assignee can change its status")
    if changes.get("status") == TaskStatus.archived:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A task is archived automatically after manager approval",
        )
    if task.status == TaskStatus.archived:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Archived tasks are read-only")
    if "assignee_id" in changes:
        if changes["assignee_id"] is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A task must have an assignee")
        if task.project_id is None:
            if changes["assignee_id"] != current_user.id:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Personal tasks must remain self-assigned")
        else:
            _validate_assignee(db, org_id, current_user, task.project_id, changes["assignee_id"])

    if current_user.role == UserRole.employee:
        if task.assignee_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only update your own tasks")
        allowed_fields = (
            _SELF_CREATED_ALLOWED_FIELDS
            if task.created_by_id == current_user.id and task.assignee_id == current_user.id
            else _EMPLOYEE_ALLOWED_FIELDS
        )
        disallowed = set(changes) - allowed_fields
        if disallowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"You may only update: {', '.join(sorted(allowed_fields))}",
            )
    elif task.project_id is not None:
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_manage_project(db, project, current_user)
    elif task.created_by_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This is a personal task")

    status_changed = "status" in changes and changes["status"] != task.status

    for field, value in changes.items():
        if field in _ACTIVITY_TRACKED_FIELDS and value != getattr(task, field):
            old_value = getattr(task, field)
            log_task_activity(
                db,
                org_id,
                task.id,
                current_user.id,
                f"task.{field}_change",
                {"from": old_value.value if hasattr(old_value, "value") else old_value,
                 "to": value.value if hasattr(value, "value") else value},
            )
        setattr(task, field, value)

    # Reaching `completed` starts the approval workflow (pending review);
    # moving away from `completed` clears any prior approval decision so a
    # stale "approved"/"rejected" badge can't linger on a re-opened task.
    # Guarded on an actual transition so re-sending the same status doesn't
    # wipe out an already-approved/rejected decision. Exception: the
    # org_admin completing a task assigned to themself skips review
    # entirely for a private no-project task. Project work always has a
    # manager review, even when the assignee is an administrator.
    if status_changed:
        if changes["status"] == TaskStatus.completed:
            task.progress_percent = 100
            task.approval_status = ApprovalStatus.pending if task.project_id is not None else None
            if task.project_id is not None:
                for reviewer_id in _task_reviewer_ids(db, org_id, task):
                    if reviewer_id != current_user.id:
                        create_notification(
                            db,
                            org_id,
                            reviewer_id,
                            NotificationType.report_submitted,
                            {
                                "kind": "task_approval",
                                "task_id": str(task.id),
                                "task_title": task.title,
                                "project_id": str(task.project_id),
                            },
                        )
        else:
            task.approval_status = None

    db.commit()
    db.refresh(task)
    return _attach_computed_fields(db, org_id, [task])[0]


def _assert_can_approve(db: Session, org_id: uuid.UUID, current_user: User, task: Task) -> None:
    if task.project_id is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Personal tasks have no approval workflow")
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)


def approve_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> Task:
    task = get_task(db, org_id, current_user, task_id)
    _assert_can_approve(db, org_id, current_user, task)

    if task.approval_status != ApprovalStatus.pending:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only a pending task can be approved")

    task.approval_status = ApprovalStatus.approved
    task.status = TaskStatus.archived
    db.flush()

    log_task_activity(db, org_id, task.id, current_user.id, "task.approve")

    if task.assignee_id is not None and task.assignee_id != current_user.id:
        create_notification(
            db,
            org_id,
            task.assignee_id,
            NotificationType.report_reviewed,
            {"task_id": str(task.id), "task_title": task.title, "status": "approved"},
        )

    db.commit()
    db.refresh(task)
    return _attach_computed_fields(db, org_id, [task])[0]


def reject_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, review_comment: str) -> Task:
    task = get_task(db, org_id, current_user, task_id)
    _assert_can_approve(db, org_id, current_user, task)

    if task.approval_status != ApprovalStatus.pending:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only a pending task can be rejected")

    task.approval_status = ApprovalStatus.rejected
    task.status = TaskStatus.in_progress
    db.flush()

    log_task_activity(db, org_id, task.id, current_user.id, "task.reject", {"review_comment": review_comment})

    if task.assignee_id is not None and task.assignee_id != current_user.id:
        create_notification(
            db,
            org_id,
            task.assignee_id,
            NotificationType.report_reviewed,
            {"task_id": str(task.id), "task_title": task.title, "status": "rejected", "review_comment": review_comment},
        )

    db.commit()
    db.refresh(task)
    return _attach_computed_fields(db, org_id, [task])[0]


def delete_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> None:
    task = get_task(db, org_id, current_user, task_id)
    if task.project_id is not None:
        if task.created_by_id != current_user.id:
            project = get_project(db, org_id, current_user, task.project_id)
            assert_can_manage_project(db, project, current_user)
    elif task.created_by_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This is a personal task")

    log_event(db, org_id, current_user.id, "task.delete", "task", str(task.id), {"title": task.title})

    db.delete(task)
    db.commit()


def _depends_on_chain_reaches(db: Session, start_task_id: uuid.UUID, target_task_id: uuid.UUID) -> bool:
    """DFS over the depends_on graph starting at start_task_id: True if
    target_task_id is reachable, meaning adding (target -> start) would form a cycle."""
    seen: set[uuid.UUID] = set()
    stack = [start_task_id]
    while stack:
        current = stack.pop()
        if current == target_task_id:
            return True
        if current in seen:
            continue
        seen.add(current)
        deps = db.query(TaskDependency.depends_on_task_id).filter(TaskDependency.task_id == current).all()
        stack.extend(dep_id for (dep_id,) in deps)
    return False


def add_dependency(
    db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, depends_on_task_id: uuid.UUID
) -> TaskDependency:
    task = get_task(db, org_id, current_user, task_id)
    if task.project_id is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Personal tasks cannot have dependencies")
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)

    if task_id == depends_on_task_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A task cannot depend on itself")

    depends_on_task = get_task(db, org_id, current_user, depends_on_task_id)
    if depends_on_task.project_id != task.project_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Dependencies must be within the same project"
        )

    # Would adding (task_id depends_on depends_on_task_id) create a cycle?
    # That happens iff task_id is already reachable by following
    # depends_on_task_id's own dependency chain.
    if _depends_on_chain_reaches(db, depends_on_task_id, task_id):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This dependency would create a cycle")

    existing = (
        db.query(TaskDependency)
        .filter(TaskDependency.task_id == task_id, TaskDependency.depends_on_task_id == depends_on_task_id)
        .first()
    )
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Dependency already exists")

    dependency = TaskDependency(task_id=task_id, depends_on_task_id=depends_on_task_id)
    db.add(dependency)
    db.commit()
    db.refresh(dependency)
    return dependency


def list_dependencies(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> list[TaskDependency]:
    get_task(db, org_id, current_user, task_id)  # enforces view access
    return db.query(TaskDependency).filter(TaskDependency.task_id == task_id).all()
