import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.calendar_event import (
    CalendarEventCategoryCreate,
    CalendarEventCategoryOut,
    CalendarEventCreate,
    CalendarEventOut,
    CalendarEventUpdate,
)
from app.services import calendar_events as calendar_events_service

router = APIRouter(prefix="/calendar-events", tags=["calendar-events"])
categories_router = APIRouter(prefix="/calendar-event-categories", tags=["calendar-events"])


@categories_router.get("", response_model=list[CalendarEventCategoryOut])
def list_categories(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[CalendarEventCategoryOut]:
    return [CalendarEventCategoryOut.model_validate(item) for item in calendar_events_service.list_categories(db, org_id)]


@categories_router.post("", response_model=CalendarEventCategoryOut, status_code=201)
def create_category(
    data: CalendarEventCategoryCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> CalendarEventCategoryOut:
    return CalendarEventCategoryOut.model_validate(
        calendar_events_service.create_category(db, org_id, current_user, data)
    )


@router.post("", response_model=CalendarEventOut, status_code=201)
def create_event(
    data: CalendarEventCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> CalendarEventOut:
    event = calendar_events_service.create_event(db, org_id, current_user, data)
    return CalendarEventOut.model_validate(event)


@router.get("", response_model=list[CalendarEventOut])
def list_events(
    start: datetime = Query(..., description="Range start (inclusive)"),
    end: datetime = Query(..., description="Range end (exclusive)"),
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[CalendarEventOut]:
    events = calendar_events_service.list_events(db, org_id, current_user, start, end)
    return [CalendarEventOut.model_validate(e) for e in events]


@router.patch("/{event_id}", response_model=CalendarEventOut)
def update_event(
    event_id: uuid.UUID,
    data: CalendarEventUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> CalendarEventOut:
    event = calendar_events_service.update_event(db, org_id, current_user, event_id, data)
    return CalendarEventOut.model_validate(event)


@router.delete("/{event_id}", status_code=204)
def delete_event(
    event_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    calendar_events_service.delete_event(db, org_id, current_user, event_id)
