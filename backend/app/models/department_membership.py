import uuid

from sqlalchemy import Enum, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import UserRole


class DepartmentMembership(UUIDPKMixin, TimestampMixin, Base):
    """A user's membership in one department, with a role scoped to that
    department -- lets a user belong to several departments (e.g. a
    project_manager in Engineering who's also just an employee in Finance)
    instead of the single User.department_id/.role pair covering only one.
    org_admin doesn't need rows here: that role is organization-wide, not
    department-scoped (see api/deps.py::require_role, which still reads
    User.role directly and is unaffected by this table)."""

    __tablename__ = "department_memberships"
    __table_args__ = (UniqueConstraint("user_id", "department_id", name="uq_department_membership_user_department"),)

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    department_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("departments.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # Restricted to project_manager/employee at the application layer (see
    # schemas/user.py::DepartmentMembershipIn) -- reuses the existing
    # "userrole" enum type rather than declaring a new one (see migration).
    role: Mapped[UserRole] = mapped_column(Enum(UserRole, name="userrole"), nullable=False)

    department: Mapped["Department"] = relationship()
