import uuid
from datetime import date
from typing import Literal

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.enums import WorkLogStatus
from app.models.project import Project
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog
from app.services.dashboard import get_visible_project_ids
from app.services.projects import assert_can_manage_project, get_project


def query_worklog_report(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID | None = None,
    user_id: uuid.UUID | None = None,
    status_filter: WorkLogStatus | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
) -> dict:
    # Manage-level: this is per-member worklog detail (activity text, who
    # logged it), not a view a plain project member should be able to pull
    # for the whole project just because they can see it exists.
    if project_id is not None:
        project = get_project(db, org_id, current_user, project_id)
        assert_can_manage_project(db, project, current_user)
        project_ids = [project_id]
    else:
        project_ids = get_visible_project_ids(db, org_id, current_user)

    if not project_ids:
        return {"items": [], "total_minutes": 0, "total_hours": 0.0}

    query = (
        db.query(WorkLog, Task.title, Task.project_id, Project.name, User.full_name)
        .join(Task, WorkLog.task_id == Task.id)
        .join(Project, Task.project_id == Project.id)
        .join(User, WorkLog.user_id == User.id)
        .filter(WorkLog.organization_id == org_id, Task.project_id.in_(project_ids))
    )
    if user_id is not None:
        query = query.filter(WorkLog.user_id == user_id)
    if status_filter is not None:
        query = query.filter(WorkLog.status == status_filter)
    if date_from is not None:
        query = query.filter(WorkLog.log_date >= date_from)
    if date_to is not None:
        query = query.filter(WorkLog.log_date <= date_to)

    rows = query.order_by(WorkLog.log_date.desc()).all()

    items = [
        {
            "worklog_id": wl.id,
            "task_id": wl.task_id,
            "task_title": task_title,
            "project_id": project_id_,
            "project_name": project_name,
            "user_id": wl.user_id,
            "user_full_name": user_full_name,
            "activity_description": wl.activity_description,
            "time_spent_minutes": wl.time_spent_minutes,
            "progress_percent": wl.progress_percent,
            "log_date": wl.log_date,
            "status": wl.status,
            "created_at": wl.created_at,
        }
        for wl, task_title, project_id_, project_name, user_full_name in rows
    ]
    total_minutes = sum(item["time_spent_minutes"] for item in items)

    return {"items": items, "total_minutes": total_minutes, "total_hours": round(total_minutes / 60, 2)}


def query_worklog_trend(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID | None = None,
    group_by: Literal["week", "month"] = "week",
    date_from: date | None = None,
    date_to: date | None = None,
) -> dict:
    """Approved hours bucketed by week/month, for the Analytics trend chart
    -- a second view of the same WorkLog data the dashboard/reports already
    expose, just aggregated over time instead of a snapshot."""
    if project_id is not None:
        project = get_project(db, org_id, current_user, project_id)
        assert_can_manage_project(db, project, current_user)
        project_ids = [project_id]
    else:
        project_ids = get_visible_project_ids(db, org_id, current_user)

    if not project_ids:
        return {"items": []}

    period = func.date_trunc(group_by, WorkLog.log_date).label("period")
    query = (
        db.query(period, func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(Task, WorkLog.task_id == Task.id)
        .filter(
            WorkLog.organization_id == org_id,
            Task.project_id.in_(project_ids),
            WorkLog.status == WorkLogStatus.approved,
        )
    )
    if date_from is not None:
        query = query.filter(WorkLog.log_date >= date_from)
    if date_to is not None:
        query = query.filter(WorkLog.log_date <= date_to)

    rows = query.group_by(period).order_by(period).all()

    return {
        "items": [
            {"period": period_start.date(), "approved_hours": round(minutes / 60, 2)}
            for period_start, minutes in rows
        ]
    }
