import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import WorkLogStatus
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog
from app.schemas.worklog import WorkLogCreate
from app.services.projects import assert_can_manage_project, assert_can_view_project, get_project
from app.services.tasks import get_task


class WorkLogRepository(TenantScopedRepository[WorkLog]):
    model = WorkLog


def create_worklog(db: Session, org_id: uuid.UUID, current_user: User, data: WorkLogCreate) -> WorkLog:
    # get_task already enforces that the caller can view the task's project.
    task = get_task(db, org_id, current_user, data.task_id)

    # A worklog records "I did work on this task", so it only makes sense
    # against a task actually assigned to the person logging it.
    if task.assignee_id != current_user.id:
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
    )
    db.add(worklog)
    db.commit()
    db.refresh(worklog)
    return worklog


def get_worklog(db: Session, org_id: uuid.UUID, current_user: User, worklog_id: uuid.UUID) -> WorkLog:
    worklog = WorkLogRepository(db, org_id).get(worklog_id)
    if worklog is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Work log not found")
    task = get_task(db, org_id, current_user, worklog.task_id)
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
    project = get_project(db, org_id, current_user, project_id)
    assert_can_view_project(db, project, current_user)

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


def _assert_can_review(db: Session, org_id: uuid.UUID, current_user: User, worklog: WorkLog) -> None:
    task = get_task(db, org_id, current_user, worklog.task_id)
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)


def approve_worklog(db: Session, org_id: uuid.UUID, current_user: User, worklog_id: uuid.UUID) -> WorkLog:
    worklog = get_worklog(db, org_id, current_user, worklog_id)
    _assert_can_review(db, org_id, current_user, worklog)

    if worklog.status != WorkLogStatus.submitted:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only submitted work logs can be reviewed")

    worklog.status = WorkLogStatus.approved
    worklog.reviewed_by_id = current_user.id
    worklog.review_comment = None
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
    db.commit()
    db.refresh(worklog)
    return worklog
