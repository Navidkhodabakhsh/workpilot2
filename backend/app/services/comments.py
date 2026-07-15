import uuid

from sqlalchemy.orm import Session

from app.models.enums import NotificationType
from app.models.collaboration import Comment
from app.models.user import User
from app.services.notifications import create_notification
from app.services.tasks import get_task


def _to_dict(comment: Comment, author_full_name: str) -> dict:
    return {
        "id": comment.id,
        "task_id": comment.task_id,
        "author_id": comment.author_id,
        "author_full_name": author_full_name,
        "body": comment.body,
        "created_at": comment.created_at,
    }


def create_comment(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, body: str) -> dict:
    task = get_task(db, org_id, current_user, task_id)  # enforces view access

    comment = Comment(organization_id=org_id, task_id=task_id, author_id=current_user.id, body=body)
    db.add(comment)
    db.flush()

    if task.assignee_id is not None and task.assignee_id != current_user.id:
        create_notification(
            db,
            org_id,
            task.assignee_id,
            NotificationType.comment_added,
            {"task_id": str(task.id), "task_title": task.title, "author_full_name": current_user.full_name},
        )

    db.commit()
    db.refresh(comment)
    return _to_dict(comment, current_user.full_name)


def list_comments(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> list[dict]:
    get_task(db, org_id, current_user, task_id)  # enforces view access

    rows = (
        db.query(Comment, User.full_name)
        .join(User, Comment.author_id == User.id)
        .filter(Comment.organization_id == org_id, Comment.task_id == task_id)
        .order_by(Comment.created_at)
        .all()
    )
    return [_to_dict(comment, full_name) for comment, full_name in rows]
