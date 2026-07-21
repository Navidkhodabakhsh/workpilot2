import uuid

from sqlalchemy import Boolean, Enum, ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import UserRole


class User(UUIDPKMixin, TimestampMixin, Base):
    """A membership: one Account acting with one role inside one
    organization. Identity (phone/password) lives on Account, not here --
    see models/account.py. The same account_id can appear on several User
    rows (one per organization_id), each with an independent role."""

    __tablename__ = "users"
    __table_args__ = (
        UniqueConstraint("account_id", "organization_id", name="uq_user_account_organization"),
    )

    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("accounts.id"), nullable=False, index=True
    )
    # Nullable only for platform_admin, who is not scoped to any organization.
    organization_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=True, index=True
    )

    full_name: Mapped[str] = mapped_column(String(200), nullable=False)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), nullable=False, default=UserRole.employee)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    # Primary/default department -- still used everywhere it already was
    # (user creation default, list filtering). A user can additionally
    # belong to other departments via department_memberships below, each
    # with its own role; this column doesn't attempt to stay in sync with
    # that table beyond both being set at creation time.
    department_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("departments.id", ondelete="SET NULL"), nullable=True
    )

    account: Mapped["Account"] = relationship(back_populates="users")
    organization: Mapped["Organization"] = relationship(back_populates="users")
    department_memberships: Mapped[list["DepartmentMembership"]] = relationship(
        cascade="all, delete-orphan", order_by="DepartmentMembership.created_at"
    )
