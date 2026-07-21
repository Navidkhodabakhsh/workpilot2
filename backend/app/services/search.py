import uuid

from sqlalchemy.orm import Session

from app.models.project import Project
from app.models.task import Task
from app.models.user import User
from app.services.dashboard import get_visible_project_ids

RESULT_LIMIT = 5


def search(db: Session, org_id: uuid.UUID, current_user: User, query: str) -> dict:
    like = f"%{query}%"
    project_ids = get_visible_project_ids(db, org_id, current_user)

    if not project_ids:
        return {"projects": [], "tasks": [], "users": []}

    projects = (
        db.query(Project)
        .filter(Project.id.in_(project_ids), Project.name.ilike(like))
        .order_by(Project.name)
        .limit(RESULT_LIMIT)
        .all()
    )
    tasks = (
        db.query(Task)
        .filter(Task.project_id.in_(project_ids), Task.title.ilike(like))
        .order_by(Task.title)
        .limit(RESULT_LIMIT)
        .all()
    )
    users = (
        db.query(User)
        .filter(User.organization_id == org_id, User.full_name.ilike(like))
        .order_by(User.full_name)
        .limit(RESULT_LIMIT)
        .all()
    )

    return {"projects": projects, "tasks": tasks, "users": users}
