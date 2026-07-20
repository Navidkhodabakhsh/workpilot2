import uuid
from datetime import date

from sqlalchemy import Date, Enum, ForeignKey, Numeric, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import FinanceEntryType


class FinanceCategory(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "finance_categories"
    __table_args__ = (
        UniqueConstraint("organization_id", "entry_type", "name", name="uq_finance_category_org_type_name"),
    )

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    entry_type: Mapped[FinanceEntryType] = mapped_column(
        Enum(FinanceEntryType, name="financeentrytype"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    color: Mapped[str] = mapped_column(String(20), nullable=False, default="#64748b")
    is_system: Mapped[bool] = mapped_column(nullable=False, default=False)


class FinanceEntry(UUIDPKMixin, TimestampMixin, Base):
    """A lightweight accounting document for one income or expense event."""

    __tablename__ = "finance_entries"

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    category_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("finance_categories.id"), nullable=False, index=True
    )
    project_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("projects.id"), nullable=True, index=True
    )
    recorded_by_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False
    )
    entry_type: Mapped[FinanceEntryType] = mapped_column(
        Enum(FinanceEntryType, name="financeentrytype"), nullable=False, index=True
    )
    document_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    amount: Mapped[float] = mapped_column(Numeric(16, 2), nullable=False)
    title: Mapped[str] = mapped_column(String(240), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    document_number: Mapped[str | None] = mapped_column(String(100), nullable=True)
    counterparty: Mapped[str | None] = mapped_column(String(200), nullable=True)

    category: Mapped[FinanceCategory] = relationship()
