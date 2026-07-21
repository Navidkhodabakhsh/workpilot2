import uuid
from datetime import datetime

from fastapi import HTTPException, status
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.calendar_event import CalendarEvent, CalendarEventCategory
from app.models.enums import CalendarEventType, UserRole
from app.models.user import User
from app.schemas.calendar_event import CalendarEventCategoryCreate, CalendarEventCreate, CalendarEventUpdate
from app.services.dashboard import get_visible_project_ids
from app.services.projects import assert_can_view_project, get_project

# Employees can only self-serve the two personal event types; everything
# else (meetings, holidays) requires org_admin/project_manager.
_EMPLOYEE_ALLOWED_TYPES = {CalendarEventType.leave, CalendarEventType.reminder}

# Seed rows matching the colors the four event types have always rendered
# with (see frontend EVENT_TYPE_COLOR), so a fresh org's category picker
# starts out visually consistent with the existing type-based legend.
DEFAULT_CATEGORIES = (
    ("جلسه", "#16a34a"),
    ("مرخصی", "#9333ea"),
    ("تعطیلی", "#dc2626"),
    ("یادآوری", "#d97706"),
)


class CalendarEventRepository(TenantScopedRepository[CalendarEvent]):
    model = CalendarEvent


def _ensure_default_categories(db: Session, org_id: uuid.UUID) -> None:
    existing = {
        name
        for (name,) in db.query(CalendarEventCategory.name)
        .filter(CalendarEventCategory.organization_id == org_id)
        .all()
    }
    created = False
    for name, color in DEFAULT_CATEGORIES:
        if name not in existing:
            db.add(CalendarEventCategory(organization_id=org_id, name=name, color=color, is_system=True))
            created = True
    if created:
        db.commit()


def list_categories(db: Session, org_id: uuid.UUID) -> list[CalendarEventCategory]:
    _ensure_default_categories(db, org_id)
    return (
        db.query(CalendarEventCategory)
        .filter(CalendarEventCategory.organization_id == org_id)
        .order_by(CalendarEventCategory.name)
        .all()
    )


def _assert_can_manage_categories(current_user: User) -> None:
    if current_user.role not in {UserRole.org_admin, UserRole.project_manager}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organization and project managers can manage calendar categories",
        )


def create_category(
    db: Session, org_id: uuid.UUID, current_user: User, data: CalendarEventCategoryCreate
) -> CalendarEventCategory:
    _assert_can_manage_categories(current_user)
    duplicate = (
        db.query(CalendarEventCategory)
        .filter(
            CalendarEventCategory.organization_id == org_id,
            func.lower(CalendarEventCategory.name) == data.name.strip().lower(),
        )
        .first()
    )
    if duplicate:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Category already exists")
    category = CalendarEventCategory(
        organization_id=org_id, name=data.name.strip(), color=data.color, is_system=False
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


def _validate_category(db: Session, org_id: uuid.UUID, category_id: uuid.UUID | None) -> None:
    if category_id is None:
        return
    exists = (
        db.query(CalendarEventCategory.id)
        .filter(CalendarEventCategory.id == category_id, CalendarEventCategory.organization_id == org_id)
        .first()
    )
    if exists is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Calendar category not found")


def _attach_category_info(db: Session, org_id: uuid.UUID, events: list[CalendarEvent]) -> list[CalendarEvent]:
    category_ids = {e.category_id for e in events if e.category_id is not None}
    categories = (
        {
            c.id: c
            for c in db.query(CalendarEventCategory)
            .filter(CalendarEventCategory.organization_id == org_id, CalendarEventCategory.id.in_(category_ids))
            .all()
        }
        if category_ids
        else {}
    )
    for event in events:
        category = categories.get(event.category_id)
        event.category_name = category.name if category else None
        event.category_color = category.color if category else None
    return events


def create_event(db: Session, org_id: uuid.UUID, current_user: User, data: CalendarEventCreate) -> CalendarEvent:
    if current_user.role == UserRole.employee:
        if data.event_type not in _EMPLOYEE_ALLOWED_TYPES:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Employees may only create leave or reminder events",
            )
        if data.user_id is not None and data.user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Employees may only create events for themselves",
            )
        user_id = current_user.id
    else:
        user_id = data.user_id

    if data.project_id is not None:
        project = get_project(db, org_id, current_user, data.project_id)
        assert_can_view_project(db, project, current_user)

    _validate_category(db, org_id, data.category_id)

    event = CalendarEvent(
        organization_id=org_id,
        created_by_id=current_user.id,
        project_id=data.project_id,
        user_id=user_id,
        category_id=data.category_id,
        title=data.title,
        description=data.description,
        event_type=data.event_type,
        start_at=data.start_at,
        end_at=data.end_at,
        all_day=data.all_day,
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return _attach_category_info(db, org_id, [event])[0]


def list_events(
    db: Session, org_id: uuid.UUID, current_user: User, start: datetime, end: datetime
) -> list[CalendarEvent]:
    query = db.query(CalendarEvent).filter(
        CalendarEvent.organization_id == org_id,
        CalendarEvent.start_at < end,
        CalendarEvent.end_at >= start,
    )

    if current_user.role == UserRole.org_admin:
        return _attach_category_info(db, org_id, query.all())

    # Org-wide events (no project): holidays and general meetings are visible
    # to everyone; leave/reminder are visible only to their own user and to
    # whoever created them, plus every leave/reminder to project managers
    # (who need team-availability visibility to plan work).
    visible_project_ids = get_visible_project_ids(db, org_id, current_user)
    org_wide_types = [CalendarEventType.holiday, CalendarEventType.meeting]
    conditions = [
        (CalendarEvent.project_id.is_(None)) & (CalendarEvent.event_type.in_(org_wide_types)),
        CalendarEvent.user_id == current_user.id,
        CalendarEvent.created_by_id == current_user.id,
    ]
    if visible_project_ids:
        conditions.append(CalendarEvent.project_id.in_(visible_project_ids))
    if current_user.role == UserRole.project_manager:
        conditions.append(CalendarEvent.event_type.in_([CalendarEventType.leave, CalendarEventType.reminder]))

    return _attach_category_info(db, org_id, query.filter(or_(*conditions)).all())


def get_event(db: Session, org_id: uuid.UUID, current_user: User, event_id: uuid.UUID) -> CalendarEvent:
    event = CalendarEventRepository(db, org_id).get(event_id)
    if event is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
    _assert_can_manage(db, org_id, current_user, event)
    return event


def _assert_can_manage(db: Session, org_id: uuid.UUID, current_user: User, event: CalendarEvent) -> None:
    if current_user.role == UserRole.org_admin:
        return
    if event.created_by_id == current_user.id or event.user_id == current_user.id:
        return
    if event.project_id is not None:
        project = get_project(db, org_id, current_user, event.project_id)
        assert_can_view_project(db, project, current_user)
        if current_user.role == UserRole.project_manager:
            return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You cannot modify this event")


def update_event(
    db: Session, org_id: uuid.UUID, current_user: User, event_id: uuid.UUID, data: CalendarEventUpdate
) -> CalendarEvent:
    event = get_event(db, org_id, current_user, event_id)
    changes = data.model_dump(exclude_unset=True)

    new_start = changes.get("start_at", event.start_at)
    new_end = changes.get("end_at", event.end_at)
    if new_end < new_start:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="end_at must not be before start_at")

    if "category_id" in changes:
        _validate_category(db, org_id, changes["category_id"])

    for field, value in changes.items():
        setattr(event, field, value)

    db.commit()
    db.refresh(event)
    return _attach_category_info(db, org_id, [event])[0]


def delete_event(db: Session, org_id: uuid.UUID, current_user: User, event_id: uuid.UUID) -> None:
    event = get_event(db, org_id, current_user, event_id)
    db.delete(event)
    db.commit()
