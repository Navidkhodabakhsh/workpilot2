from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin


class Account(UUIDPKMixin, TimestampMixin, Base):
    """The actual login identity: one phone number + password. A single
    Account can have many `User` rows -- one per organization it belongs
    to, each with its own role -- so the same phone number can be an
    org_admin in one organization and an employee in another."""

    __tablename__ = "accounts"

    phone_number: Mapped[str] = mapped_column(String(32), unique=True, index=True, nullable=False)
    # Nullable: an account invited by phone only (no password set by the
    # inviter) has no password until they complete OTP verification and set
    # one themselves -- see services/otp.py.
    hashed_password: Mapped[str | None] = mapped_column(String(255), nullable=True)

    users: Mapped[list["User"]] = relationship(back_populates="account")
