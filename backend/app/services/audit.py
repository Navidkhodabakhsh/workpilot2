import uuid

from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog

# No update/delete function is defined anywhere for AuditLog -- that
# omission is the enforcement mechanism for "immutable audit trail"
# (RFB section 5, "ثبت فعالیت‌های کاربران به‌صورت غیرقابل تغییر").


def log_event(
    db: Session,
    org_id: uuid.UUID | None,
    actor_user_id: uuid.UUID | None,
    action: str,
    entity_type: str,
    entity_id: str,
    metadata: dict | None = None,
) -> AuditLog:
    entry = AuditLog(
        organization_id=org_id,
        actor_user_id=actor_user_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        extra_metadata=metadata or {},
    )
    db.add(entry)
    db.flush()
    return entry
