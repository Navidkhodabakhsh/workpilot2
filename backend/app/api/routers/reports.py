import uuid
from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import WorkLogStatus
from app.models.user import User
from app.schemas.report import WorkLogReport
from app.services import reports as reports_service

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/worklogs", response_model=WorkLogReport)
def get_worklog_report(
    project_id: uuid.UUID | None = None,
    user_id: uuid.UUID | None = None,
    status_filter: WorkLogStatus | None = Query(default=None, alias="status"),
    date_from: date | None = None,
    date_to: date | None = None,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> WorkLogReport:
    data = reports_service.query_worklog_report(
        db, org_id, current_user, project_id, user_id, status_filter, date_from, date_to
    )
    return WorkLogReport.model_validate(data)
