import uuid
from datetime import date

from fastapi import HTTPException, status
from sqlalchemy import and_, func, or_
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import ApprovalStatus, NotificationType, TaskStatus, UserRole, WorkLogStatus
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


def _attach_actual_hours(db: Session, org_id: uuid.UUID, tasks: list[Task]) -> list[Task]:
    """actual_hours is never stored -- it's the sum of approved WorkLog
    minutes for each task, same aggregation style as dashboard.py/reports.py."""
    if not tasks:
        return tasks
    task_ids = [t.id for t in tasks]
    rows = (
        db.query(WorkLog.task_id, func.sum(WorkLog.time_spent_minutes))
        .filter(
            WorkLog.organization_id == org_id,
            WorkLog.task_id.in_(task_ids),
            WorkLog.status == WorkLogStatus.approved,
        )
        .group_by(WorkLog.task_id)
        .all()
    )
    minutes_by_task = dict(rows)
    for task in tasks:
        task.actual_hours = round((minutes_by_task.get(task.id) or 0) / 60, 2)
    return tasks


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
        _can_manage_project_tasks(db, org_id, current_user, data.project_id)
        assignee_id = data.assignee_id

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
    return _attach_actual_hours(db, org_id, [task])[0]


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
    else:
        # No project given -- list across every project the user can see
        # (same visibility rule the dashboard/reports/search endpoints use),
        # plus the caller's own personal tasks, for the global Tasks view.
        visible_project_ids = get_visible_project_ids(db, org_id, current_user)
        own_personal_tasks = and_(Task.project_id.is_(None), Task.created_by_id == current_user.id)
        visibility_clause = (
            or_(Task.project_id.in_(visible_project_ids), own_personal_tasks)
            if visible_project_ids
            else own_personal_tasks
        )
        query = db.query(Task).filter(Task.organization_id == org_id, visibility_clause)

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

    tasks = query.all()
    return _attach_actual_hours(db, org_id, tasks)


def get_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> Task:
    task = TaskRepository(db, org_id).get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.project_id is None:
        if task.created_by_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This is a personal task")
    else:
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_view_project(db, project, current_user)
    return _attach_actual_hours(db, org_id, [task])[0]


# Fields an `employee` is allowed to change on a task assigned to them.
_EMPLOYEE_ALLOWED_FIELDS = {"status", "progress_percent"}

_ACTIVITY_TRACKED_FIELDS = {"status", "assignee_id", "priority"}


def update_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, data: TaskUpdate) -> Task:
    task = get_task(db, org_id, current_user, task_id)
    changes = data.model_dump(exclude_unset=True)

    if current_user.role == UserRole.employee:
        if task.assignee_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only update your own tasks")
        disallowed = set(changes) - _EMPLOYEE_ALLOWED_FIELDS
        if disallowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Employees may only update: {', '.join(sorted(_EMPLOYEE_ALLOWED_FIELDS))}",
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
    # wipe out an already-approved/rejected decision.
    if status_changed:
        if changes["status"] == TaskStatus.completed:
            task.approval_status = ApprovalStatus.pending
        else:
            task.approval_status = None

    db.commit()
    db.refresh(task)
    return _attach_actual_hours(db, org_id, [task])[0]


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
    return _attach_actual_hours(db, org_id, [task])[0]


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
    return _attach_actual_hours(db, org_id, [task])[0]


def delete_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> None:
    task = get_task(db, org_id, current_user, task_id)
    if task.project_id is not None:
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
