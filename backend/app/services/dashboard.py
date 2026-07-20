import uuid

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.enums import WorkLogStatus
from app.models.project import Project
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog
from app.services.projects import list_projects


def get_visible_project_ids(db: Session, org_id: uuid.UUID, current_user: User) -> list[uuid.UUID]:
    return [p.id for p in list_projects(db, org_id, current_user)]


def get_summary(db: Session, org_id: uuid.UUID, current_user: User, department_id: uuid.UUID | None = None) -> dict:
    project_ids = get_visible_project_ids(db, org_id, current_user)
    if department_id is not None:
        rows = (
            db.query(Project.id)
            .filter(Project.id.in_(project_ids), Project.department_id == department_id)
            .all()
        )
        project_ids = [pid for (pid,) in rows]

    if not project_ids:
        return {
            "project_count": 0,
            "projects_by_status": [],
            "task_count": 0,
            "tasks_by_status": [],
            "total_approved_hours": 0.0,
            "team_hours": [],
            "recent_activity": [],
        }

    projects_by_status = (
        db.query(Project.status, func.count(Project.id))
        .filter(Project.id.in_(project_ids))
        .group_by(Project.status)
        .all()
    )

    tasks_by_status = (
        db.query(Task.status, func.count(Task.id))
        .filter(Task.project_id.in_(project_ids))
        .group_by(Task.status)
        .all()
    )
    task_count = sum(count for _, count in tasks_by_status)

    total_minutes = (
        db.query(func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(Task, WorkLog.task_id == Task.id)
        .filter(Task.project_id.in_(project_ids), WorkLog.status == WorkLogStatus.approved)
        .scalar()
    )

    team_minutes = (
        db.query(WorkLog.user_id, User.full_name, func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(Task, WorkLog.task_id == Task.id)
        .join(User, WorkLog.user_id == User.id)
        .filter(Task.project_id.in_(project_ids), WorkLog.status == WorkLogStatus.approved)
        .group_by(WorkLog.user_id, User.full_name)
        .all()
    )

    recent = (
        db.query(WorkLog, Task.title, User.full_name)
        .join(Task, WorkLog.task_id == Task.id)
        .join(User, WorkLog.user_id == User.id)
        .filter(Task.project_id.in_(project_ids))
        .order_by(WorkLog.created_at.desc())
        .limit(10)
        .all()
    )

    return {
        "project_count": len(project_ids),
        "projects_by_status": [{"status": s.value, "count": c} for s, c in projects_by_status],
        "task_count": task_count,
        "tasks_by_status": [{"status": s.value, "count": c} for s, c in tasks_by_status],
        "total_approved_hours": round((total_minutes or 0) / 60, 2),
        "team_hours": [
            {"user_id": uid, "full_name": name, "approved_hours": round(minutes / 60, 2)}
            for uid, name, minutes in team_minutes
        ],
        "recent_activity": [
            {
                "worklog_id": wl.id,
                "task_id": wl.task_id,
                "task_title": task_title,
                "user_id": wl.user_id,
                "user_full_name": user_name,
                "status": wl.status.value,
                "created_at": wl.created_at.isoformat(),
            }
            for wl, task_title, user_name in recent
        ],
    }
