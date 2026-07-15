import uuid

from pydantic import BaseModel, EmailStr, Field, field_validator

from app.models.enums import UserRole
from app.schemas.validators import validate_password_strength


class SignupRequest(BaseModel):
    organization_name: str = Field(min_length=2, max_length=200)
    full_name: str = Field(min_length=2, max_length=200)
    email: EmailStr
    phone_number: str | None = Field(default=None, max_length=32)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("password")
    @classmethod
    def _password_strength(cls, value: str) -> str:
        return validate_password_strength(value)


class LoginRequest(BaseModel):
    # Deliberately a plain string, not EmailStr: login accepts either an
    # email or a phone number, whichever the user prefers.
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

    model_config = {"from_attributes": True}
