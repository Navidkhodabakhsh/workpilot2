import uuid

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator

from app.models.enums import OtpPurpose, UserRole
from app.schemas.validators import validate_password_strength


class SignupRequest(BaseModel):
    organization_name: str = Field(min_length=2, max_length=200)
    full_name: str = Field(min_length=2, max_length=200)
    email: EmailStr
    # Required: login is phone-first, so the founding admin needs one too.
    phone_number: str = Field(min_length=8, max_length=32)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("password")
    @classmethod
    def _password_strength(cls, value: str) -> str:
        return validate_password_strength(value)


class LoginRequest(BaseModel):
    # Deliberately a plain string, not EmailStr: the API still accepts
    # either an email or a phone number here (the login *page* only exposes
    # a phone field, but e.g. platform_admin tooling may still use email).
    identifier: str = Field(min_length=3, max_length=255)
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID | None
    email: EmailStr
    phone_number: str | None
    full_name: str
    role: UserRole
    is_active: bool
    has_password: bool

    model_config = {"from_attributes": True}

    @model_validator(mode="before")
    @classmethod
    def _compute_has_password(cls, data):
        # `data` is the raw ORM User object when built via model_validate(user).
        # has_password isn't a real column -- attach it as a plain instance
        # attribute so from_attributes' getattr picks it up like any other
        # field (same pattern as Task.actual_hours in schemas/task.py).
        if hasattr(data, "hashed_password"):
            data.has_password = data.hashed_password is not None
        return data


class OtpRequestIn(BaseModel):
    phone_number: str = Field(min_length=8, max_length=32)
    purpose: OtpPurpose


class OtpRequestOut(BaseModel):
    message: str
    # Populated only when no real SMS provider is configured yet (see
    # settings.sms_provider_configured) -- never set this in production.
    debug_code: str | None = None


class OtpLoginIn(BaseModel):
    phone_number: str = Field(min_length=8, max_length=32)
    code: str = Field(min_length=6, max_length=6)
    new_password: str | None = Field(default=None, min_length=8, max_length=128)

    @field_validator("new_password")
    @classmethod
    def _password_strength(cls, value: str | None) -> str | None:
        return validate_password_strength(value) if value is not None else None


class OtpResetPasswordIn(BaseModel):
    phone_number: str = Field(min_length=8, max_length=32)
    code: str = Field(min_length=6, max_length=6)
    new_password: str = Field(min_length=8, max_length=128)

    @field_validator("new_password")
    @classmethod
    def _password_strength(cls, value: str) -> str:
        return validate_password_strength(value)
