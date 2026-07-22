import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import NotificationType, TaskStatus, UserRole, WorkLogStatus
from app.models.project import Project, ProjectMember
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog
from app.schemas.worklog import WorkLogCreate
from app.services.audit import log_event
from app.services.notifications import create_notification
from app.services.projects import assert_can_manage_project, assert_can_view_project, get_project
from app.services.tasks import get_task


class WorkLogRepository(TenantScopedRepository[WorkLog]):
    model = WorkLog


def create_worklog(db: Session, org_id: uuid.UUID, current_user: User, data: WorkLogCreate) -> WorkLog:
    # get_task already enforces that the caller can view the task's project.
    task = get_task(db, org_id, current_user, data.task_id)

    if task.status == TaskStatus.archived:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Work cannot be logged on an archived task",
        )

    # Only the assignee actually does the work, so only the assignee may
    # record hours -- a manager who merely created/assigned the task reviews
    # and approves those hours instead (see approve_worklog/reject_worklog).
    if current_user.id != task.assignee_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only log work on tasks assigned to you",
        )

    worklog = WorkLog(
        organization_id=org_id,
        task_id=task.id,
        user_id=current_user.id,
        activity_description=data.activity_description,
        time_spent_minutes=data.time_spent_minutes,
        progress_percent=data.progress_percent,
        log_date=data.log_date,
        # Private, no-project tasks have no reviewer and therefore finalize
        # immediately. Every project worklog is submitted for manager review.
        status=WorkLogStatus.approved if task.project_id is None else WorkLogStatus.submitted,
    )
    db.add(worklog)
    db.flush()

    # Progress only moves once hours are actually approved -- a personal
    # (no-project) task's worklog auto-approves right above, but a project
    # task's worklog stays `submitted` until a manager reviews it, so its
    # progress update is deferred to approve_worklog() below instead.
    if worklog.status == WorkLogStatus.approved and data.progress_percent > task.progress_percent:
        task.progress_percent = data.progress_percent

    # Notify whoever created the task (the closest thing we have to "the
    # manager who assigned this work") rather than every project manager,
    # to avoid notification spam on projects with several managers.
    if task.project_id is not None:
        project = db.query(Project).filter(Project.id == task.project_id, Project.organization_id == org_id).first()
        reviewer_ids: set[uuid.UUID] = set()
        if project and project.manager_id:
            reviewer_ids.add(project.manager_id)
        if not reviewer_ids:
            reviewer_ids.update(
                user_id
                for (user_id,) in db.query(ProjectMember.user_id)
                .join(User, ProjectMember.user_id == User.id)
                .filter(
                    ProjectMember.project_id == task.project_id,
                    User.organization_id == org_id,
                    User.role == UserRole.project_manager,
                    User.is_active.is_(True),
                )
                .all()
            )
        if not reviewer_ids:
            reviewer_ids.update(
                user_id
                for (user_id,) in db.query(User.id)
                .filter(User.organization_id == org_id, User.role == UserRole.org_admin, User.is_active.is_(True))
                .all()
            )
        for reviewer_id in reviewer_ids:
            if reviewer_id != current_user.id:
                create_notification(
                    db,
                    org_id,
                    reviewer_id,
                    NotificationType.report_submitted,
                    {
                        "kind": "worklog_approval",
                        "worklog_id": str(worklog.id),
                        "task_id": str(task.id),
                        "task_title": task.title,
                    },
                )

    db.commit()
    db.refresh(worklog)
    return worklog


def list_task_worklogs(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    task_id: uuid.UUID,
) -> list[WorkLog]:
    """Return a task's complete time history using the task visibility rules.

    Assignees and creators can inspect their own entries, while project
    managers can inspect the same history when reviewing the task.
    """
    get_task(db, org_id, current_user, task_id)
    return (
        db.query(WorkLog)
        .filter(WorkLog.organization_id == org_id, WorkLog.task_id == task_id)
        .order_by(WorkLog.log_date.desc(), WorkLog.created_at.desc())
        .all()
    )


def get_worklog(db: Session, org_id: uuid.UUID, current_user: User, worklog_id: uuid.UUID) -> WorkLog:
    worklog = WorkLogRepository(db, org_id).get(worklog_id)
    if worklog is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Work log not found")
    task = get_task(db, org_id, current_user, worklog.task_id)
    if task.project_id is not None:
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_view_project(db, project, current_user)
    return worklog


def list_worklogs(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID,
    task_id: uuid.UUID | None = None,
    status_filter: WorkLogStatus | None = None,
) -> list[WorkLog]:
    # Manage-level, not just view-level: this returns every member's raw
    # worklog entries (including review comments), the same data the
    # manager-only approval queue is built from -- a plain project member
    # shouldn't be able to pull it by calling the endpoint directly.
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)

    query = (
        db.query(WorkLog)
        .join(Task, WorkLog.task_id == Task.id)
        .filter(WorkLog.organization_id == org_id, Task.project_id == project_id)
    )
    if task_id is not None:
        query = query.filter(WorkLog.task_id == task_id)
    if status_filter is not None:
        query = query.filter(WorkLog.status == status_filter)
    return query.all()


def _assert_can_review(db: Session, org_id: uuid.UUID, current_user: User, worklog: WorkLog) -> Task:
    task = get_task(db, org_id, current_user, worklog.task_id)
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)
    return task


def approve_worklog(db: Session, org_id: uuid.UUID, current_user: User, worklog_id: uuid.UUID) -> WorkLog:
    worklog = get_worklog(db, org_id, current_user, worklog_id)
    task = _assert_can_review(db, org_id, current_user, worklog)

    if worklog.status != WorkLogStatus.submitted:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only submitted work logs can be reviewed")

    worklog.status = WorkLogStatus.approved
    worklog.reviewed_by_id = current_user.id
    worklog.review_comment = None
    if worklog.progress_percent > task.progress_percent:
        task.progress_percent = worklog.progress_percent
    db.flush()

    log_event(db, org_id, current_user.id, "worklog.approve", "worklog", str(worklog.id))

    if worklog.user_id != current_user.id:
        create_notification(
            db,
            org_id,
            worklog.user_id,
            NotificationType.report_reviewed,
            {"worklog_id": str(worklog.id), "task_id": str(worklog.task_id), "status": "approved"},
        )

    db.commit()
    db.refresh(worklog)
    return worklog


def reject_worklog(
    db: Session, org_id: uuid.UUID, current_user: User, worklog_id: uuid.UUID, review_comment: str
) -> WorkLog:
    worklog = get_worklog(db, org_id, current_user, worklog_id)
    _assert_can_review(db, org_id, current_user, worklog)

    if worklog.status != WorkLogStatus.submitted:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only submitted work logs can be reviewed")

    worklog.status = WorkLogStatus.rejected
    worklog.reviewed_by_id = current_user.id
    worklog.review_comment = review_comment
    db.flush()

    log_event(
        db, org_id, current_user.id, "worklog.reject", "worklog", str(worklog.id), {"review_comment": review_comment}
    )

    if worklog.user_id != current_user.id:
        create_notification(
            db,
            org_id,
            worklog.user_id,
            NotificationType.report_reviewed,
            {
                "worklog_id": str(worklog.id),
                "task_id": str(worklog.task_id),
                "status": "rejected",
                "review_comment": review_comment,
            },
        )

    db.commit()
    db.refresh(worklog)
    return worklog
