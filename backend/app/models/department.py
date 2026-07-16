import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin


class Department(UUIDPKMixin, TimestampMixin, Base):
    """Logical grouping of users/projects within an organization (e.g.
    accounting, engineering, HR) -- no physical data separation, just a
    department_id column on User/Project used to scope list views client-side.
    See docs/ARCHITECTURE.md."""

    __tablename__ = "departments"

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)
