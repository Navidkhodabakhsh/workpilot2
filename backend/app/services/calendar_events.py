import uuid
from datetime import datetime

from fastapi import HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.calendar_event import CalendarEvent
from app.models.enums import CalendarEventType, UserRole
from app.models.user import User
from app.schemas.calendar_event import CalendarEventCreate, CalendarEventUpdate
from app.services.dashboard import get_visible_project_ids
from app.services.projects import assert_can_view_project, get_project

# Employees can only self-serve the two personal event types; everything
# else (meetings, holidays) requires org_admin/project_manager.
_EMPLOYEE_ALLOWED_TYPES = {CalendarEventType.leave, CalendarEventType.reminder}


class CalendarEventRepository(TenantScopedRepository[CalendarEvent]):
    model = CalendarEvent


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

    event = CalendarEvent(
        organization_id=org_id,
        created_by_id=current_user.id,
        project_id=data.project_id,
        user_id=user_id,
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
    return event


def list_events(
    db: Session, org_id: uuid.UUID, current_user: User, start: datetime, end: datetime
) -> list[CalendarEvent]:
    query = db.query(CalendarEvent).filter(
        CalendarEvent.organization_id == org_id,
        CalendarEvent.start_at < end,
        CalendarEvent.end_at >= start,
    )

    if current_user.role == UserRole.org_admin:
        return query.all()

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

    return query.filter(or_(*conditions)).all()


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

    for field, value in changes.items():
        setattr(event, field, value)

    db.commit()
    db.refresh(event)
    return event


def delete_event(db: Session, org_id: uuid.UUID, current_user: User, event_id: uuid.UUID) -> None:
    event = get_event(db, org_id, current_user, event_id)
    db.delete(event)
    db.commit()
