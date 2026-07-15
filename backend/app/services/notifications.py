import uuid
from datetime import date, timedelta

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import NotificationType, TaskStatus
from app.models.notification import Notification
from app.models.task import Task
from app.models.user import User


class NotificationRepository(TenantScopedRepository[Notification]):
    model = Notification


def create_notification(
    db: Session, org_id: uuid.UUID, user_id: uuid.UUID, notif_type: NotificationType, payload: dict
) -> Notification:
    notification = Notification(
        organization_id=org_id, user_id=user_id, type=notif_type, payload=payload
    )
    db.add(notification)
    db.flush()
    return notification


def list_notifications(
    db: Session, org_id: uuid.UUID, current_user: User, unread_only: bool = False, limit: int = 30
) -> list[Notification]:
    query = (
        db.query(Notification)
        .filter(Notification.organization_id == org_id, Notification.user_id == current_user.id)
    )
    if unread_only:
        query = query.filter(Notification.is_read.is_(False))
    return query.order_by(Notification.created_at.desc()).limit(limit).all()


def get_unread_count(db: Session, org_id: uuid.UUID, current_user: User) -> int:
    return (
        db.query(Notification)
        .filter(
            Notification.organization_id == org_id,
            Notification.user_id == current_user.id,
            Notification.is_read.is_(False),
        )
        .count()
    )


def mark_read(db: Session, org_id: uuid.UUID, current_user: User, notification_id: uuid.UUID) -> Notification:
    notification = NotificationRepository(db, org_id).get(notification_id)
    if notification is None or notification.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification


def mark_all_read(db: Session, org_id: uuid.UUID, current_user: User) -> int:
    updated = (
        db.query(Notification)
        .filter(
            Notification.organization_id == org_id,
            Notification.user_id == current_user.id,
            Notification.is_read.is_(False),
        )
        .update({"is_read": True})
    )
    db.commit()
    return updated


# --- Deadline reminders (system/background job, not user-initiated) ---

DEADLINE_WARNING_DAYS = 2


def check_deadlines_approaching(db: Session) -> int:
    """Runs across all organizations (Celery beat job, no request context).
    Notifies each task's assignee once per task -- if a deadline_approaching
    notification already exists for a task, it is not sent again, even if
    this job runs daily. This means changing a task's deadline after the
    first reminder won't trigger a second one; acceptable for now, documented
    in docs/PROJECT_STATE.md as a known simplification."""
    horizon = date.today() + timedelta(days=DEADLINE_WARNING_DAYS)

    upcoming_tasks = (
        db.query(Task)
        .filter(
            Task.deadline.isnot(None),
            Task.deadline <= horizon,
            Task.deadline >= date.today(),
            Task.status.notin_([TaskStatus.completed, TaskStatus.archived]),
            Task.assignee_id.isnot(None),
        )
        .all()
    )

    already_notified_task_ids = {
        row[0]
        for row in db.query(Notification.payload["task_id"].astext)
        .filter(Notification.type == NotificationType.deadline_approaching)
        .all()
    }

    created = 0
    for task in upcoming_tasks:
        if str(task.id) in already_notified_task_ids:
            continue
        create_notification(
            db,
            task.organization_id,
            task.assignee_id,
            NotificationType.deadline_approaching,
            {"task_id": str(task.id), "task_title": task.title, "deadline": task.deadline.isoformat()},
        )
        created += 1

    db.commit()
    return created
