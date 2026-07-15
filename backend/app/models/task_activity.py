import uuid

from sqlalchemy import DateTime, ForeignKey, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base_class import Base, UUIDPKMixin


class TaskActivityLog(UUIDPKMixin, Base):
    """Per-task activity trail (creation, status/assignee/priority change,
    comment, attachment, approve/reject). Same immutability rule as AuditLog
    (app/models/audit_log.py) -- no update/delete is ever exposed for this
    model, only inserts and reads via GET /tasks/{id}/activity."""

    __tablename__ = "task_activity_logs"

    created_at: Mapped[object] = mapped_column(DateTime(timezone=True), server_default=func.now())

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    task_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True)
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    action: Mapped[str] = mapped_column(String(100), nullable=False)
    extra_metadata: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
