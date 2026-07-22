import uuid

from pydantic import BaseModel, Field, field_validator, model_validator

from app.models.enums import OtpPurpose, UserRole
from app.schemas.user import DepartmentMembershipOut
from app.schemas.validators import validate_password_strength


class SignupRequest(BaseModel):
    organization_name: str = Field(min_length=2, max_length=200)
    # Optional: an organization can start undivided and add departments
    # later from Settings (see services/auth.py::signup).
    department_name: str | None = Field(default=None, min_length=2, max_length=200)
    full_name: str = Field(min_length=2, max_length=200)
    # Login is phone-first; the founding admin needs a phone number.
    phone_number: str = Field(min_length=8, max_length=32)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("password")
    @classmethod
    def _password_strength(cls, value: str) -> str:
        return validate_password_strength(value)


class LoginRequest(BaseModel):
    phone_number: str = Field(min_length=8, max_length=32)
    password: str


class CreateOrganizationRequest(BaseModel):
    """Lets an already-authenticated account found an additional
    organization (becoming its org_admin) without creating a new identity --
    this is what lets one phone number be org_admin of one org and a member
    of another. Deliberately a separate, authenticated action rather than
    something public signup detects/merges into, so a public endpoint can
    never be used to probe whether a phone number already has an account."""

    organization_name: str = Field(min_length=2, max_length=200)
    department_name: str | None = Field(default=None, min_length=2, max_length=200)


class OrganizationMembershipOut(BaseModel):
    organization_id: uuid.UUID
    organization_name: str
    role: UserRole

    model_config = {"from_attributes": True}


class SwitchOrganizationRequest(BaseModel):
    organization_id: uuid.UUID


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID | None
    phone_number: str
    full_name: str
    role: UserRole
    is_active: bool
    has_password: bool
    department_id: uuid.UUID | None
    department_memberships: list[DepartmentMembershipOut] = []

    model_config = {"from_attributes": True}

    @model_validator(mode="before")
    @classmethod
    def _flatten_account_fields(cls, data):
        # `data` is the raw ORM User object when built via model_validate(user).
        # phone_number/has_password aren't real columns on User anymore --
        # attach them as plain instance attributes so from_attributes'
        # getattr picks them up like any other field (same pattern as
        # Task.actual_hours in schemas/task.py).
        if hasattr(data, "account"):
            data.phone_number = data.account.phone_number
            data.has_password = data.account.hashed_password is not None
        return data


class OtpRequestIn(BaseModel):
    phone_number: str = Field(min_length=8, max_length=32)
    purpose: OtpPurpose


class OtpRequestOut(BaseModel):
    message: str
    # Populated only when KAVENEGAR_API_KEY isn't set (local dev/testing) --
    # never populated once real SMS delivery is configured.
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
