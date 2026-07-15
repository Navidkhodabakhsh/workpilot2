import uuid

from sqlalchemy.orm import Session

from app.models.task_activity import TaskActivityLog
from app.models.user import User

# No update/delete function is defined anywhere for TaskActivityLog -- that
# omission is the enforcement mechanism for "immutable per-task activity
# trail", same pattern as app/services/audit.py.


def log_task_activity(
    db: Session,
    org_id: uuid.UUID,
    task_id: uuid.UUID,
    actor_user_id: uuid.UUID | None,
    action: str,
    metadata: dict | None = None,
) -> TaskActivityLog:
    entry = TaskActivityLog(
        organization_id=org_id,
        task_id=task_id,
        actor_user_id=actor_user_id,
        action=action,
        extra_metadata=metadata or {},
    )
    db.add(entry)
    db.flush()
    return entry


def list_task_activity(db: Session, org_id: uuid.UUID, task_id: uuid.UUID) -> list[tuple[TaskActivityLog, str | None]]:
    return (
        db.query(TaskActivityLog, User.full_name)
        .outerjoin(User, TaskActivityLog.actor_user_id == User.id)
        .filter(TaskActivityLog.organization_id == org_id, TaskActivityLog.task_id == task_id)
        .order_by(TaskActivityLog.created_at)
        .all()
    )
