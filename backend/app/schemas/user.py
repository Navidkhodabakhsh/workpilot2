from pydantic import BaseModel, EmailStr, Field, field_validator

from app.models.enums import UserRole
from app.schemas.validators import validate_password_strength


class OrgUserCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=200)
    email: EmailStr
    # Required: login is phone-first, so every new user needs one to ever
    # sign in. Password is optional -- omit it to invite the person by
    # phone only; they set their own password on first OTP login.
    phone_number: str = Field(min_length=8, max_length=32)
    password: str | None = Field(default=None, min_length=8, max_length=128)
    role: UserRole = UserRole.employee

    @field_validator("password")
    @classmethod
    def _password_strength(cls, value: str | None) -> str | None:
        return validate_password_strength(value) if value is not None else None

    @field_validator("role")
    @classmethod
    def _no_platform_admin(cls, value: UserRole) -> UserRole:
        if value == UserRole.platform_admin:
            raise ValueError("platform_admin cannot be assigned within an organization")
        return value


class UserUpdate(BaseModel):
    role: UserRole | None = None
    is_active: bool | None = None
    phone_number: str | None = Field(default=None, min_length=8, max_length=32)

    @field_validator("role")
    @classmethod
    def _no_platform_admin(cls, value: UserRole | None) -> UserRole | None:
        if value == UserRole.platform_admin:
            raise ValueError("platform_admin cannot be assigned within an organization")
        return value
