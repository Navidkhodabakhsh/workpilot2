import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.enums import FinanceEntryType


class FinanceCategoryCreate(BaseModel):
    entry_type: FinanceEntryType
    name: str = Field(min_length=2, max_length=120)
    color: str = Field(default="#64748b", pattern=r"^#[0-9a-fA-F]{6}$")


class FinanceCategoryOut(BaseModel):
    id: uuid.UUID
    entry_type: FinanceEntryType
    name: str
    color: str
    is_system: bool

    model_config = {"from_attributes": True}


class FinanceEntryCreate(BaseModel):
    category_id: uuid.UUID
    project_id: uuid.UUID | None = None
    entry_type: FinanceEntryType
    document_date: date
    amount: Decimal = Field(gt=0, max_digits=16, decimal_places=2)
    title: str = Field(min_length=2, max_length=240)
    description: str | None = Field(default=None, max_length=4000)
    document_number: str | None = Field(default=None, max_length=100)
    counterparty: str | None = Field(default=None, max_length=200)


class FinanceEntryUpdate(BaseModel):
    category_id: uuid.UUID | None = None
    project_id: uuid.UUID | None = None
    document_date: date | None = None
    amount: Decimal | None = Field(default=None, gt=0, max_digits=16, decimal_places=2)
    title: str | None = Field(default=None, min_length=2, max_length=240)
    description: str | None = Field(default=None, max_length=4000)
    document_number: str | None = Field(default=None, max_length=100)
    counterparty: str | None = Field(default=None, max_length=200)


class FinanceEntryOut(BaseModel):
    id: uuid.UUID
    category_id: uuid.UUID
    category_name: str
    category_color: str
    project_id: uuid.UUID | None
    project_name: str | None
    recorded_by_id: uuid.UUID
    entry_type: FinanceEntryType
    document_date: date
    amount: Decimal
    title: str
    description: str | None
    document_number: str | None
    counterparty: str | None
    created_at: datetime

    model_config = {"from_attributes": True}


class FinanceBreakdownItem(BaseModel):
    category_id: uuid.UUID
    category_name: str
    color: str
    amount: Decimal
    percent: float


class FinanceSummary(BaseModel):
    total_income: Decimal
    total_expense: Decimal
    balance: Decimal
    income_breakdown: list[FinanceBreakdownItem]
    expense_breakdown: list[FinanceBreakdownItem]

