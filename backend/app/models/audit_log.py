import uuid

from sqlalchemy import DateTime, ForeignKey, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base_class import Base, UUIDPKMixin


class AuditLog(UUIDPKMixin, Base):
    """Immutable audit trail. No update/delete operations are exposed for this
    model anywhere in the service layer — only inserts and reads."""

    __tablename__ = "audit_logs"

    created_at: Mapped[object] = mapped_column(DateTime(timezone=True), server_default=func.now())

    # Nullable: platform-level events (e.g. organization created by platform_admin)
    # are not scoped to any single organization.
    organization_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=True, index=True
    )
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    action: Mapped[str] = mapped_column(String(100), nullable=False)
    entity_type: Mapped[str] = mapped_column(String(100), nullable=False)
    entity_id: Mapped[str] = mapped_column(String(100), nullable=False)
    extra_metadata: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
