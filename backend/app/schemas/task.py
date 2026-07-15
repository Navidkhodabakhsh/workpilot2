import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field

from app.models.enums import ApprovalStatus, TaskPriority, TaskStatus


class TaskCreate(BaseModel):
    # Optional: omitted means a personal task (assignee forced to the
    # creator by the service layer).
    project_id: uuid.UUID | None = None
    parent_task_id: uuid.UUID | None = None
    title: str = Field(min_length=2, max_length=300)
    description: str | None = None
    assignee_id: uuid.UUID | None = None
    priority: TaskPriority = TaskPriority.medium
    deadline: date | None = None
    estimated_hours: float | None = Field(default=None, ge=0, le=9999)


class TaskUpdate(BaseModel):
    """All fields optional; the service layer restricts which of these an
    `employee` may actually change (status/progress on their own task) versus
    org_admin/project_manager (everything)."""

    title: str | None = Field(default=None, min_length=2, max_length=300)
    description: str | None = None
    assignee_id: uuid.UUID | None = None
    priority: TaskPriority | None = None
    status: TaskStatus | None = None
    progress_percent: int | None = Field(default=None, ge=0, le=100)
    estimated_hours: float | None = Field(default=None, ge=0, le=9999)
    deadline: date | None = None


class TaskRejectRequest(BaseModel):
    review_comment: str = Field(min_length=2, max_length=2000)


class TaskOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    project_id: uuid.UUID | None
    parent_task_id: uuid.UUID | None
    assignee_id: uuid.UUID | None
    created_by_id: uuid.UUID
    title: str
    description: str | None
    priority: TaskPriority
    status: TaskStatus
    approval_status: ApprovalStatus | None
    progress_percent: int
    estimated_hours: float | None
    actual_hours: float = 0
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


class TaskActivityOut(BaseModel):
    id: uuid.UUID
    task_id: uuid.UUID
    actor_user_id: uuid.UUID | None
    actor_full_name: str | None
    action: str
    extra_metadata: dict
    created_at: datetime

    model_config = {"from_attributes": True}
