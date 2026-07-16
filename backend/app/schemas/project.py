import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field

from app.models.enums import ProjectStatus


class ProjectCreate(BaseModel):
    name: str = Field(min_length=2, max_length=200)
    description: str | None = None
    cooperation_start_date: date | None = None
    start_date: date | None = None
    end_date: date | None = None
    manager_id: uuid.UUID | None = None
    department_id: uuid.UUID | None = None
    member_ids: list[uuid.UUID] = Field(default_factory=list)


class ProjectUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=200)
    description: str | None = None
    cooperation_start_date: date | None = None
    start_date: date | None = None
    end_date: date | None = None
    status: ProjectStatus | None = None
    manager_id: uuid.UUID | None = None
    department_id: uuid.UUID | None = None


class ProjectOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    name: str
    description: str | None
    cooperation_start_date: date | None
    start_date: date | None
    end_date: date | None
    status: ProjectStatus
    created_by_id: uuid.UUID
    manager_id: uuid.UUID | None
    department_id: uuid.UUID | None
    created_at: datetime

    model_config = {"from_attributes": True}


class ProjectMemberAdd(BaseModel):
    user_id: uuid.UUID


class ProjectMemberOut(BaseModel):
    id: uuid.UUID
    project_id: uuid.UUID
    user_id: uuid.UUID

    model_config = {"from_attributes": True}
