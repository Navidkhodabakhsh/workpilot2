import uuid

from pydantic import BaseModel, Field, field_validator, model_validator

from app.models.enums import UserRole
from app.schemas.validators import validate_password_strength


class OrgUserCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=200)
    # Required: login is phone-first, so every new user needs one to ever
    # sign in. If this phone number already has an account (e.g. they're a
    # member of another organization), it's silently reused as their
    # identity here and `password` below is ignored -- see
    # services/users.py::create_org_user. Password is otherwise optional --
    # omit it to invite the person by phone only; they set their own
    # password on first OTP login.
    phone_number: str = Field(min_length=8, max_length=32)
    password: str | None = Field(default=None, min_length=8, max_length=128)
    role: UserRole = UserRole.employee
    department_id: uuid.UUID | None = None

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
    department_id: uuid.UUID | None = None
    # Sets a new password for this user directly (an org_admin action) --
    # distinct from the self-service change-password flow, which requires
    # the current password. Changes the shared Account, so it affects login
    # for every organization this person belongs to.
    password: str | None = Field(default=None, min_length=8, max_length=128)

    @field_validator("role")
    @classmethod
    def _no_platform_admin(cls, value: UserRole | None) -> UserRole | None:
        if value == UserRole.platform_admin:
            raise ValueError("platform_admin cannot be assigned within an organization")
        return value

    @field_validator("password")
    @classmethod
    def _password_strength(cls, value: str | None) -> str | None:
        return validate_password_strength(value) if value is not None else None


class DepartmentMembershipIn(BaseModel):
    department_id: uuid.UUID
    # org_admin/platform_admin aren't department-scoped roles (see
    # models/department_membership.py) -- only these two make sense here.
    role: UserRole = UserRole.employee

    @field_validator("role")
    @classmethod
    def _department_role_only(cls, value: UserRole) -> UserRole:
        if value not in (UserRole.project_manager, UserRole.employee):
            raise ValueError("Department membership role must be project_manager or employee")
        return value


class DepartmentMembershipOut(BaseModel):
    department_id: uuid.UUID
    department_name: str
    role: UserRole

    model_config = {"from_attributes": True}

    @model_validator(mode="before")
    @classmethod
    def _flatten_department_name(cls, data):
        # Same "ghost field" pattern as UserOut.has_password / Task.actual_hours
        # -- department_name isn't a real column, it comes from the related
        # Department via the ORM relationship.
        if hasattr(data, "department"):
            data.department_name = data.department.name
        return data
