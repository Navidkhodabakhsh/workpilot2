import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.notification import NotificationOut, UnreadCount
from app.services import notifications as notifications_service

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationOut])
def list_notifications(
    unread_only: bool = False,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[NotificationOut]:
    items = notifications_service.list_notifications(db, org_id, current_user, unread_only)
    return [NotificationOut.model_validate(n) for n in items]


@router.get("/unread-count", response_model=UnreadCount)
def unread_count(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> UnreadCount:
    count = notifications_service.get_unread_count(db, org_id, current_user)
    return UnreadCount(unread_count=count)


@router.post("/{notification_id}/read", response_model=NotificationOut)
def mark_read(
    notification_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> NotificationOut:
    notification = notifications_service.mark_read(db, org_id, current_user, notification_id)
    return NotificationOut.model_validate(notification)


@router.post("/read-all")
def mark_all_read(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> dict[str, int]:
    updated = notifications_service.mark_all_read(db, org_id, current_user)
    return {"updated": updated}
