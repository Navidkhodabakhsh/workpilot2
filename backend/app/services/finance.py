import uuid
from datetime import date
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.enums import FinanceEntryType, UserRole
from app.models.finance import FinanceCategory, FinanceEntry
from app.models.project import Project
from app.models.user import User
from app.schemas.finance import FinanceCategoryCreate, FinanceEntryCreate, FinanceEntryUpdate
from app.services.audit import log_event


DEFAULT_CATEGORIES = (
    (FinanceEntryType.income, "درآمد پروژه", "#10b981"),
    (FinanceEntryType.income, "خدمات و مشاوره", "#0ea5e9"),
    (FinanceEntryType.income, "سایر درآمدها", "#8b5cf6"),
    (FinanceEntryType.expense, "حقوق و دستمزد", "#f43f5e"),
    (FinanceEntryType.expense, "خورد و خوراک", "#f59e0b"),
    (FinanceEntryType.expense, "اجاره و قبوض", "#ef4444"),
    (FinanceEntryType.expense, "حمل‌ونقل", "#f97316"),
    (FinanceEntryType.expense, "سایر هزینه‌ها", "#64748b"),
)


def _assert_finance_access(current_user: User) -> None:
    if current_user.role not in {UserRole.org_admin, UserRole.project_manager}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only organization and project managers can access finance")


def _ensure_default_categories(db: Session, org_id: uuid.UUID) -> None:
    existing = {
        (entry_type, name)
        for entry_type, name in db.query(FinanceCategory.entry_type, FinanceCategory.name)
        .filter(FinanceCategory.organization_id == org_id)
        .all()
    }
    created = False
    for entry_type, name, color in DEFAULT_CATEGORIES:
        if (entry_type, name) not in existing:
            db.add(
                FinanceCategory(
                    organization_id=org_id,
                    entry_type=entry_type,
                    name=name,
                    color=color,
                    is_system=True,
                )
            )
            created = True
    if created:
        db.commit()


def list_categories(db: Session, org_id: uuid.UUID, current_user: User) -> list[FinanceCategory]:
    _assert_finance_access(current_user)
    _ensure_default_categories(db, org_id)
    return (
        db.query(FinanceCategory)
        .filter(FinanceCategory.organization_id == org_id)
        .order_by(FinanceCategory.entry_type, FinanceCategory.name)
        .all()
    )


def create_category(
    db: Session, org_id: uuid.UUID, current_user: User, data: FinanceCategoryCreate
) -> FinanceCategory:
    _assert_finance_access(current_user)
    duplicate = (
        db.query(FinanceCategory)
        .filter(
            FinanceCategory.organization_id == org_id,
            FinanceCategory.entry_type == data.entry_type,
            func.lower(FinanceCategory.name) == data.name.strip().lower(),
        )
        .first()
    )
    if duplicate:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Category already exists")
    category = FinanceCategory(
        organization_id=org_id,
        entry_type=data.entry_type,
        name=data.name.strip(),
        color=data.color,
        is_system=False,
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


def _get_category(db: Session, org_id: uuid.UUID, category_id: uuid.UUID) -> FinanceCategory:
    category = (
        db.query(FinanceCategory)
        .filter(FinanceCategory.id == category_id, FinanceCategory.organization_id == org_id)
        .first()
    )
    if category is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Finance category not found")
    return category


def _validate_project(db: Session, org_id: uuid.UUID, project_id: uuid.UUID | None) -> Project | None:
    if project_id is None:
        return None
    project = db.query(Project).filter(Project.id == project_id, Project.organization_id == org_id).first()
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    return project


def _attach_names(db: Session, org_id: uuid.UUID, entries: list[FinanceEntry]) -> list[FinanceEntry]:
    if not entries:
        return entries
    category_ids = {entry.category_id for entry in entries}
    categories = {
        category.id: category
        for category in db.query(FinanceCategory)
        .filter(FinanceCategory.organization_id == org_id, FinanceCategory.id.in_(category_ids))
        .all()
    }
    project_ids = {entry.project_id for entry in entries if entry.project_id is not None}
    projects = (
        dict(db.query(Project.id, Project.name).filter(Project.organization_id == org_id, Project.id.in_(project_ids)).all())
        if project_ids
        else {}
    )
    for entry in entries:
        category = categories[entry.category_id]
        entry.category_name = category.name
        entry.category_color = category.color
        entry.project_name = projects.get(entry.project_id)
    return entries


def create_entry(db: Session, org_id: uuid.UUID, current_user: User, data: FinanceEntryCreate) -> FinanceEntry:
    _assert_finance_access(current_user)
    category = _get_category(db, org_id, data.category_id)
    if category.entry_type != data.entry_type:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category type does not match document type")
    _validate_project(db, org_id, data.project_id)
    entry = FinanceEntry(
        organization_id=org_id,
        recorded_by_id=current_user.id,
        **data.model_dump(),
    )
    db.add(entry)
    db.flush()
    log_event(db, org_id, current_user.id, "finance.create", "finance_entry", str(entry.id), {"title": entry.title})
    db.commit()
    db.refresh(entry)
    return _attach_names(db, org_id, [entry])[0]


def list_entries(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    entry_type: FinanceEntryType | None = None,
    category_id: uuid.UUID | None = None,
    project_id: uuid.UUID | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
) -> list[FinanceEntry]:
    _assert_finance_access(current_user)
    query = db.query(FinanceEntry).filter(FinanceEntry.organization_id == org_id)
    if entry_type is not None:
        query = query.filter(FinanceEntry.entry_type == entry_type)
    if category_id is not None:
        query = query.filter(FinanceEntry.category_id == category_id)
    if project_id is not None:
        query = query.filter(FinanceEntry.project_id == project_id)
    if date_from is not None:
        query = query.filter(FinanceEntry.document_date >= date_from)
    if date_to is not None:
        query = query.filter(FinanceEntry.document_date <= date_to)
    entries = query.order_by(FinanceEntry.document_date.desc(), FinanceEntry.created_at.desc()).all()
    return _attach_names(db, org_id, entries)


def _get_entry(db: Session, org_id: uuid.UUID, entry_id: uuid.UUID) -> FinanceEntry:
    entry = (
        db.query(FinanceEntry)
        .filter(FinanceEntry.id == entry_id, FinanceEntry.organization_id == org_id)
        .first()
    )
    if entry is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Finance document not found")
    return entry


def update_entry(
    db: Session, org_id: uuid.UUID, current_user: User, entry_id: uuid.UUID, data: FinanceEntryUpdate
) -> FinanceEntry:
    _assert_finance_access(current_user)
    entry = _get_entry(db, org_id, entry_id)
    changes = data.model_dump(exclude_unset=True)
    if "project_id" in changes:
        _validate_project(db, org_id, changes["project_id"])
    if "category_id" in changes:
        category = _get_category(db, org_id, changes["category_id"])
        if category.entry_type != entry.entry_type:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category type does not match document type")
    for field, value in changes.items():
        setattr(entry, field, value)
    log_event(db, org_id, current_user.id, "finance.update", "finance_entry", str(entry.id))
    db.commit()
    db.refresh(entry)
    return _attach_names(db, org_id, [entry])[0]


def delete_entry(db: Session, org_id: uuid.UUID, current_user: User, entry_id: uuid.UUID) -> None:
    _assert_finance_access(current_user)
    entry = _get_entry(db, org_id, entry_id)
    log_event(db, org_id, current_user.id, "finance.delete", "finance_entry", str(entry.id), {"title": entry.title})
    db.delete(entry)
    db.commit()


def get_summary(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    date_from: date | None = None,
    date_to: date | None = None,
) -> dict:
    _assert_finance_access(current_user)
    query = (
        db.query(
            FinanceEntry.entry_type,
            FinanceEntry.category_id,
            FinanceCategory.name,
            FinanceCategory.color,
            func.coalesce(func.sum(FinanceEntry.amount), 0),
        )
        .join(FinanceCategory, FinanceEntry.category_id == FinanceCategory.id)
        .filter(FinanceEntry.organization_id == org_id)
    )
    if date_from is not None:
        query = query.filter(FinanceEntry.document_date >= date_from)
    if date_to is not None:
        query = query.filter(FinanceEntry.document_date <= date_to)
    rows = query.group_by(
        FinanceEntry.entry_type, FinanceEntry.category_id, FinanceCategory.name, FinanceCategory.color
    ).all()

    totals = {FinanceEntryType.income: Decimal("0"), FinanceEntryType.expense: Decimal("0")}
    for entry_type, _, _, _, amount in rows:
        totals[entry_type] += Decimal(amount)

    def breakdown(entry_type: FinanceEntryType) -> list[dict]:
        total = totals[entry_type]
        items = []
        for row_type, category_id, name, color, amount in rows:
            if row_type != entry_type:
                continue
            decimal_amount = Decimal(amount)
            items.append(
                {
                    "category_id": category_id,
                    "category_name": name,
                    "color": color,
                    "amount": decimal_amount,
                    "percent": round(float(decimal_amount / total * 100), 1) if total else 0,
                }
            )
        return sorted(items, key=lambda item: item["amount"], reverse=True)

    return {
        "total_income": totals[FinanceEntryType.income],
        "total_expense": totals[FinanceEntryType.expense],
        "balance": totals[FinanceEntryType.income] - totals[FinanceEntryType.expense],
        "income_breakdown": breakdown(FinanceEntryType.income),
        "expense_breakdown": breakdown(FinanceEntryType.expense),
    }
