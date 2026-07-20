import uuid
from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.department_membership import DepartmentMembership
from app.models.enums import TaskStatus, UserRole, WorkLogStatus
from app.models.project import Project, ProjectMember
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog
from app.services.projects import list_projects


def get_visible_project_ids(db: Session, org_id: uuid.UUID, current_user: User) -> list[uuid.UUID]:
    return [p.id for p in list_projects(db, org_id, current_user)]


def get_summary(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    department_id: uuid.UUID | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
) -> dict:
    project_ids = get_visible_project_ids(db, org_id, current_user)
    if department_id is not None:
        rows = (
            db.query(Project.id)
            .filter(Project.id.in_(project_ids), Project.department_id == department_id)
            .all()
        )
        project_ids = [pid for (pid,) in rows]

    projects_by_status = (
        db.query(Project.status, func.count(Project.id))
        .filter(Project.id.in_(project_ids) if project_ids else False)
        .group_by(Project.status)
        .all()
    )

    tasks_by_status = (
        db.query(Task.status, func.count(Task.id))
        .filter(Task.project_id.in_(project_ids) if project_ids else False, Task.status != TaskStatus.archived)
        .group_by(Task.status)
        .all()
    )
    task_count = sum(count for _, count in tasks_by_status)

    approved_filter = [
        Task.project_id.in_(project_ids) if project_ids else False,
        WorkLog.status == WorkLogStatus.approved,
    ]
    if date_from is not None:
        approved_filter.append(WorkLog.log_date >= date_from)
    if date_to is not None:
        approved_filter.append(WorkLog.log_date <= date_to)

    total_minutes = (
        db.query(func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(Task, WorkLog.task_id == Task.id)
        .filter(*approved_filter)
        .scalar()
    )

    team_minutes = (
        db.query(WorkLog.user_id, User.full_name, func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(Task, WorkLog.task_id == Task.id)
        .join(User, WorkLog.user_id == User.id)
        .filter(*approved_filter)
        .group_by(WorkLog.user_id, User.full_name)
        .all()
    )

    # Determine the people represented by the selected scope so a manager
    # can see every department member, including members with zero approved
    # hours in the selected period.
    if current_user.role == UserRole.org_admin:
        member_query = db.query(User.id, User.full_name).filter(
            User.organization_id == org_id,
            User.is_active.is_(True),
            User.role.in_([UserRole.project_manager, UserRole.employee]),
        )
    elif current_user.role == UserRole.project_manager:
        member_ids = db.query(ProjectMember.user_id).filter(
            ProjectMember.project_id.in_(project_ids) if project_ids else False
        )
        logged_user_ids = [user_id for user_id, _, _ in team_minutes]
        member_query = db.query(User.id, User.full_name).filter(
            User.organization_id == org_id,
            User.is_active.is_(True),
            User.id.in_(member_ids) | User.id.in_(logged_user_ids),
        )
    else:
        member_query = db.query(User.id, User.full_name).filter(User.id == current_user.id)

    if department_id is not None:
        department_user_ids = db.query(DepartmentMembership.user_id).filter(
            DepartmentMembership.organization_id == org_id,
            DepartmentMembership.department_id == department_id,
        )
        member_query = member_query.filter(
            (User.department_id == department_id) | User.id.in_(department_user_ids)
        )

    members = member_query.order_by(User.full_name).all()
    minutes_by_user = {user_id: minutes or 0 for user_id, _, minutes in team_minutes}
    total_team_minutes = sum(minutes_by_user.get(user_id, 0) for user_id, _ in members)

    project_minutes_rows = (
        db.query(Task.project_id, func.coalesce(func.sum(WorkLog.time_spent_minutes), 0))
        .join(WorkLog, WorkLog.task_id == Task.id)
        .filter(*approved_filter)
        .group_by(Task.project_id)
        .all()
    )
    minutes_by_project = dict(project_minutes_rows)
    project_names = dict(
        db.query(Project.id, Project.name).filter(Project.id.in_(project_ids) if project_ids else False).all()
    )
    total_project_minutes = sum(minutes_by_project.values())

    recent_query = (
        db.query(WorkLog, Task.title, User.full_name)
        .join(Task, WorkLog.task_id == Task.id)
        .join(User, WorkLog.user_id == User.id)
        .filter(Task.project_id.in_(project_ids) if project_ids else False)
    )
    if date_from is not None:
        recent_query = recent_query.filter(WorkLog.log_date >= date_from)
    if date_to is not None:
        recent_query = recent_query.filter(WorkLog.log_date <= date_to)
    recent = recent_query.order_by(WorkLog.created_at.desc()).limit(10).all()

    return {
        "project_count": len(project_ids),
        "projects_by_status": [{"status": s.value, "count": c} for s, c in projects_by_status],
        "task_count": task_count,
        "tasks_by_status": [{"status": s.value, "count": c} for s, c in tasks_by_status],
        "total_approved_hours": round((total_minutes or 0) / 60, 2),
        "team_hours": [
            {
                "user_id": uid,
                "full_name": name,
                "approved_hours": round(minutes_by_user.get(uid, 0) / 60, 2),
                "percent": round(minutes_by_user.get(uid, 0) / total_team_minutes * 100, 1)
                if total_team_minutes
                else 0,
            }
            for uid, name in members
        ],
        "project_hours": [
            {
                "project_id": project_id,
                "project_name": project_names[project_id],
                "approved_hours": round((minutes_by_project.get(project_id) or 0) / 60, 2),
                "percent": round((minutes_by_project.get(project_id) or 0) / total_project_minutes * 100, 1)
                if total_project_minutes
                else 0,
            }
            for project_id in project_ids
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
