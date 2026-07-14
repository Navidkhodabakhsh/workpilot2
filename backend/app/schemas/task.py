import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field

from app.models.enums import TaskPriority, TaskStatus


class TaskCreate(BaseModel):
    project_id: uuid.UUID
    parent_task_id: uuid.UUID | None = None
    title: str = Field(min_length=2, max_length=300)
    description: str | None = None
    assignee_id: uuid.UUID | None = None
    priority: TaskPriority = TaskPriority.medium
    deadline: date | None = None


class TaskUpdate(BaseModel):
    """All fields optional; the service layer restricts which of these an
    `employee` may actually change (status only) versus org_admin/project_manager
    (everything)."""

    title: str | None = Field(default=None, min_length=2, max_length=300)
    description: str | None = None
    assignee_id: uuid.UUID | None = None
    priority: TaskPriority | None = None
    status: TaskStatus | None = None
    deadline: date | None = None


class TaskOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    project_id: uuid.UUID
    parent_task_id: uuid.UUID | None
    assignee_id: uuid.UUID | None
    created_by_id: uuid.UUID
    title: str
    description: str | None
    priority: TaskPriority
    status: TaskStatus
    deadline: date | None
    created_at: datetime

    model_config = {"from_attributes": True}


class TaskDependencyCreate(BaseModel):
    depends_on_task_id: uuid.UUID


class TaskDependencyOut(BaseModel):
    id: uuid.UUID
    task_id: uuid.UUID
    depends_on_task_id: uuid.UUID

    model_config = {"from_attributes": True}
