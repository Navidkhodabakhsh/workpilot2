import uuid
from datetime import date
from typing import Literal

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import FinanceEntryType
from app.models.user import User
from app.schemas.finance import (
    FinanceCategoryCreate,
    FinanceCategoryOut,
    FinanceEntryCreate,
    FinanceEntryOut,
    FinanceEntryUpdate,
    FinanceSummary,
)
from app.services import finance as finance_service


router = APIRouter(prefix="/finance", tags=["finance"])


@router.get("/categories", response_model=list[FinanceCategoryOut])
def list_categories(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[FinanceCategoryOut]:
    return [FinanceCategoryOut.model_validate(item) for item in finance_service.list_categories(db, org_id, current_user)]


@router.post("/categories", response_model=FinanceCategoryOut, status_code=201)
def create_category(
    data: FinanceCategoryCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FinanceCategoryOut:
    return FinanceCategoryOut.model_validate(finance_service.create_category(db, org_id, current_user, data))


@router.get("/entries", response_model=list[FinanceEntryOut])
def list_entries(
    entry_type: FinanceEntryType | None = Query(default=None, alias="type"),
    category_id: uuid.UUID | None = None,
    project_id: uuid.UUID | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
    sort: Literal["document_date", "document_number", "amount", "title", "created_at"] = "document_date",
    order: Literal["asc", "desc"] = "desc",
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[FinanceEntryOut]:
    rows = finance_service.list_entries(
        db, org_id, current_user, entry_type, category_id, project_id, date_from, date_to, sort, order
    )
    return [FinanceEntryOut.model_validate(row) for row in rows]


@router.post("/entries", response_model=FinanceEntryOut, status_code=201)
def create_entry(
    data: FinanceEntryCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FinanceEntryOut:
    return FinanceEntryOut.model_validate(finance_service.create_entry(db, org_id, current_user, data))


@router.patch("/entries/{entry_id}", response_model=FinanceEntryOut)
def update_entry(
    entry_id: uuid.UUID,
    data: FinanceEntryUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FinanceEntryOut:
    return FinanceEntryOut.model_validate(finance_service.update_entry(db, org_id, current_user, entry_id, data))


@router.delete("/entries/{entry_id}", status_code=204)
def delete_entry(
    entry_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    finance_service.delete_entry(db, org_id, current_user, entry_id)


@router.get("/summary", response_model=FinanceSummary)
def get_summary(
    date_from: date | None = None,
    date_to: date | None = None,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FinanceSummary:
    return FinanceSummary.model_validate(finance_service.get_summary(db, org_id, current_user, date_from, date_to))

