import uuid
from datetime import date

from sqlalchemy import Date, Enum, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import WorkLogStatus


class WorkLog(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "worklogs"

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    task_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )

    activity_description: Mapped[str] = mapped_column(Text, nullable=False)
    time_spent_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    progress_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    log_date: Mapped[date] = mapped_column(Date, nullable=False)

    status: Mapped[WorkLogStatus] = mapped_column(
        Enum(WorkLogStatus), nullable=False, default=WorkLogStatus.submitted
    )
    reviewed_by_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    review_comment: Mapped[str | None] = mapped_column(Text, nullable=True)

    task: Mapped["Task"] = relationship()
