import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field


class PaymentCreate(BaseModel):
    payment_date: date
    description: str = Field(min_length=1, max_length=1000)
    amount: Decimal = Field(gt=0)


class PaymentOut(BaseModel):
    id: uuid.UUID
    project_id: uuid.UUID
    recorded_by_id: uuid.UUID
    payment_date: date
    description: str
    amount: Decimal
    created_at: datetime

    model_config = {"from_attributes": True}
