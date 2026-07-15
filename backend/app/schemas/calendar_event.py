import uuid
from datetime import datetime

from pydantic import BaseModel, Field, model_validator

from app.models.enums import CalendarEventType


class CalendarEventCreate(BaseModel):
    title: str = Field(min_length=2, max_length=300)
    description: str | None = None
    event_type: CalendarEventType
    start_at: datetime
    end_at: datetime
    all_day: bool = False
    project_id: uuid.UUID | None = None
    user_id: uuid.UUID | None = None

    @model_validator(mode="after")
    def _end_after_start(self) -> "CalendarEventCreate":
        if self.end_at < self.start_at:
            raise ValueError("end_at must not be before start_at")
        return self


class CalendarEventUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=2, max_length=300)
    description: str | None = None
    start_at: datetime | None = None
    end_at: datetime | None = None
    all_day: bool | None = None


class CalendarEventOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    created_by_id: uuid.UUID
    project_id: uuid.UUID | None
    user_id: uuid.UUID | None
    title: str
    description: str | None
    event_type: CalendarEventType
    start_at: datetime
    end_at: datetime
    all_day: bool
    created_at: datetime

    model_config = {"from_attributes": True}
