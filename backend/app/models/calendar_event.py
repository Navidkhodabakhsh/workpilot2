import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import CalendarEventType


class CalendarEventCategory(UUIDPKMixin, TimestampMixin, Base):
    """A free-form, per-org label+color for organizing events beyond the
    fixed event_type enum (which stays purely structural/role-gating)."""

    __tablename__ = "calendar_event_categories"
    __table_args__ = (
        UniqueConstraint("organization_id", "name", name="uq_calendar_event_category_org_name"),
    )

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    color: Mapped[str] = mapped_column(String(20), nullable=False, default="#64748b")
    is_system: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class CalendarEvent(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "calendar_events"

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    created_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    # Optional: a project meeting is scoped to that project's members; a
    # holiday/org-wide meeting has no project. See services/calendar_events.py
    # for the full visibility rule.
    project_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("projects.id"), nullable=True, index=True
    )
    # Optional: the person a leave/reminder belongs to (defaults to the
    # creator for self-service leave/reminders).
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True, index=True
    )
    # Optional: a free-form sub-label on top of event_type (e.g. splitting
    # "meeting" into "budget review" vs "client call"), purely cosmetic.
    category_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("calendar_event_categories.id"), nullable=True, index=True
    )

    title: Mapped[str] = mapped_column(String(300), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    event_type: Mapped[CalendarEventType] = mapped_column(Enum(CalendarEventType), nullable=False)
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    all_day: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    project: Mapped["Project"] = relationship()
    category: Mapped[CalendarEventCategory | None] = relationship()
