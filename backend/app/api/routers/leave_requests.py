import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.leave_request import LeaveRequestCreate, LeaveRequestOut, LeaveRequestReview
from app.services import leave_requests as leave_requests_service

router = APIRouter(prefix="/leave-requests", tags=["leave-requests"])


@router.post("", response_model=LeaveRequestOut, status_code=201)
def create_leave_request(
    data: LeaveRequestCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> LeaveRequestOut:
    leave_request = leave_requests_service.create_leave_request(db, org_id, current_user, data)
    return LeaveRequestOut.model_validate(leave_request)


@router.get("", response_model=list[LeaveRequestOut])
def list_leave_requests(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[LeaveRequestOut]:
    requests = leave_requests_service.list_leave_requests(db, org_id, current_user)
    return [LeaveRequestOut.model_validate(r) for r in requests]


@router.get("/{leave_request_id}", response_model=LeaveRequestOut)
def get_leave_request(
    leave_request_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> LeaveRequestOut:
    leave_request = leave_requests_service.get_leave_request(db, org_id, current_user, leave_request_id)
    return LeaveRequestOut.model_validate(leave_request)


@router.post("/{leave_request_id}/approve", response_model=LeaveRequestOut)
def approve_leave_request(
    leave_request_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> LeaveRequestOut:
    leave_request = leave_requests_service.approve_leave_request(db, org_id, current_user, leave_request_id)
    return LeaveRequestOut.model_validate(leave_request)


@router.post("/{leave_request_id}/reject", response_model=LeaveRequestOut)
def reject_leave_request(
    leave_request_id: uuid.UUID,
    data: LeaveRequestReview,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> LeaveRequestOut:
    leave_request = leave_requests_service.reject_leave_request(
        db, org_id, current_user, leave_request_id, data.review_comment
    )
    return LeaveRequestOut.model_validate(leave_request)
