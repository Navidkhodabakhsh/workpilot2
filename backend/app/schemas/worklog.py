import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field

from app.models.enums import WorkLogStatus


class WorkLogCreate(BaseModel):
    task_id: uuid.UUID
    activity_description: str = Field(min_length=2, max_length=2000)
    time_spent_minutes: int = Field(gt=0, le=24 * 60)
    progress_percent: int = Field(ge=0, le=100)
    log_date: date


class WorkLogReject(BaseModel):
    review_comment: str = Field(min_length=2, max_length=2000)


class WorkLogOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    task_id: uuid.UUID
    user_id: uuid.UUID
    activity_description: str
    time_spent_minutes: int
    progress_percent: int
    log_date: date
    status: WorkLogStatus
    reviewed_by_id: uuid.UUID | None
    review_comment: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
