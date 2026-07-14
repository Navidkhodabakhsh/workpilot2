import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import WorkLogStatus
from app.models.user import User
from app.schemas.worklog import WorkLogCreate, WorkLogOut, WorkLogReject
from app.services import worklogs as worklogs_service

router = APIRouter(prefix="/worklogs", tags=["worklogs"])


@router.post("", response_model=WorkLogOut, status_code=201)
def create_worklog(
    data: WorkLogCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> WorkLogOut:
    worklog = worklogs_service.create_worklog(db, org_id, current_user, data)
    return WorkLogOut.model_validate(worklog)


@router.get("", response_model=list[WorkLogOut])
def list_worklogs(
    project_id: uuid.UUID,
    task_id: uuid.UUID | None = None,
    status_filter: WorkLogStatus | None = Query(default=None, alias="status"),
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[WorkLogOut]:
    worklogs = worklogs_service.list_worklogs(db, org_id, current_user, project_id, task_id, status_filter)
    return [WorkLogOut.model_validate(w) for w in worklogs]


@router.get("/{worklog_id}", response_model=WorkLogOut)
def get_worklog(
    worklog_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> WorkLogOut:
    worklog = worklogs_service.get_worklog(db, org_id, current_user, worklog_id)
    return WorkLogOut.model_validate(worklog)


@router.post("/{worklog_id}/approve", response_model=WorkLogOut)
def approve_worklog(
    worklog_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> WorkLogOut:
    worklog = worklogs_service.approve_worklog(db, org_id, current_user, worklog_id)
    return WorkLogOut.model_validate(worklog)


@router.post("/{worklog_id}/reject", response_model=WorkLogOut)
def reject_worklog(
    worklog_id: uuid.UUID,
    data: WorkLogReject,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> WorkLogOut:
    worklog = worklogs_service.reject_worklog(db, org_id, current_user, worklog_id, data.review_comment)
    return WorkLogOut.model_validate(worklog)
