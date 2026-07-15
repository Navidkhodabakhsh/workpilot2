import uuid

from pydantic import BaseModel, Field, field_validator

from app.schemas.validators import validate_password_strength


class ProfileUpdate(BaseModel):
    full_name: str = Field(min_length=2, max_length=200)


class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)

    @field_validator("new_password")
    @classmethod
    def _password_strength(cls, value: str) -> str:
        return validate_password_strength(value)


class OrganizationOut(BaseModel):
    id: uuid.UUID
    name: str

    model_config = {"from_attributes": True}


class OrganizationUpdate(BaseModel):
    name: str = Field(min_length=2, max_length=200)
