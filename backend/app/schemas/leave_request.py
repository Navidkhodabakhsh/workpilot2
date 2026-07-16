import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field, model_validator

from app.models.enums import ApprovalStatus


class LeaveRequestCreate(BaseModel):
    start_date: date
    end_date: date
    reason: str | None = Field(default=None, max_length=2000)

    @model_validator(mode="after")
    def _check_date_order(self) -> "LeaveRequestCreate":
        if self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        return self


class LeaveRequestReview(BaseModel):
    review_comment: str | None = Field(default=None, max_length=2000)


class LeaveRequestOut(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    user_id: uuid.UUID
    user_full_name: str | None = None
    start_date: date
    end_date: date
    reason: str | None
    status: ApprovalStatus
    reviewed_by_id: uuid.UUID | None
    review_comment: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
