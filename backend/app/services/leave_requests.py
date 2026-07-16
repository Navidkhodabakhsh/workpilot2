import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.enums import ApprovalStatus, NotificationType, UserRole
from app.models.leave_request import LeaveRequest
from app.models.user import User
from app.schemas.leave_request import LeaveRequestCreate
from app.services.notifications import create_notification


def _can_review(current_user: User) -> bool:
    return current_user.role in (UserRole.org_admin, UserRole.project_manager)


def _attach_user_name(db: Session, requests: list[LeaveRequest]) -> list[LeaveRequest]:
    if not requests:
        return requests
    user_ids = {r.user_id for r in requests}
    name_by_user = dict(db.query(User.id, User.full_name).filter(User.id.in_(user_ids)).all())
    for r in requests:
        r.user_full_name = name_by_user.get(r.user_id)
    return requests


def create_leave_request(db: Session, org_id: uuid.UUID, current_user: User, data: LeaveRequestCreate) -> LeaveRequest:
    leave_request = LeaveRequest(
        organization_id=org_id,
        user_id=current_user.id,
        start_date=data.start_date,
        end_date=data.end_date,
        reason=data.reason,
        status=ApprovalStatus.pending,
    )
    db.add(leave_request)
    db.commit()
    db.refresh(leave_request)
    return _attach_user_name(db, [leave_request])[0]


def list_leave_requests(db: Session, org_id: uuid.UUID, current_user: User) -> list[LeaveRequest]:
    query = db.query(LeaveRequest).filter(LeaveRequest.organization_id == org_id)
    if not _can_review(current_user):
        query = query.filter(LeaveRequest.user_id == current_user.id)
    requests = query.order_by(LeaveRequest.created_at.desc()).all()
    return _attach_user_name(db, requests)


def get_leave_request(db: Session, org_id: uuid.UUID, current_user: User, leave_request_id: uuid.UUID) -> LeaveRequest:
    leave_request = (
        db.query(LeaveRequest)
        .filter(LeaveRequest.id == leave_request_id, LeaveRequest.organization_id == org_id)
        .first()
    )
    if leave_request is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Leave request not found")
    if leave_request.user_id != current_user.id and not _can_review(current_user):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not allowed to view this leave request")
    return _attach_user_name(db, [leave_request])[0]


def _review(
    db: Session, org_id: uuid.UUID, current_user: User, leave_request_id: uuid.UUID, new_status: ApprovalStatus, review_comment: str | None
) -> LeaveRequest:
    if not _can_review(current_user):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only a manager can review leave requests")

    leave_request = (
        db.query(LeaveRequest)
        .filter(LeaveRequest.id == leave_request_id, LeaveRequest.organization_id == org_id)
        .first()
    )
    if leave_request is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Leave request not found")
    if leave_request.status != ApprovalStatus.pending:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only pending leave requests can be reviewed")

    leave_request.status = new_status
    leave_request.reviewed_by_id = current_user.id
    leave_request.review_comment = review_comment
    db.flush()

    if leave_request.user_id != current_user.id:
        create_notification(
            db,
            org_id,
            leave_request.user_id,
            NotificationType.leave_reviewed,
            {
                "leave_request_id": str(leave_request.id),
                "status": new_status.value,
                "review_comment": review_comment,
            },
        )

    db.commit()
    db.refresh(leave_request)
    return _attach_user_name(db, [leave_request])[0]


def approve_leave_request(db: Session, org_id: uuid.UUID, current_user: User, leave_request_id: uuid.UUID) -> LeaveRequest:
    return _review(db, org_id, current_user, leave_request_id, ApprovalStatus.approved, None)


def reject_leave_request(
    db: Session, org_id: uuid.UUID, current_user: User, leave_request_id: uuid.UUID, review_comment: str | None
) -> LeaveRequest:
    return _review(db, org_id, current_user, leave_request_id, ApprovalStatus.rejected, review_comment)
