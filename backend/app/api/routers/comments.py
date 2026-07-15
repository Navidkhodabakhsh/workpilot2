import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentOut
from app.services import comments as comments_service

router = APIRouter(prefix="/tasks/{task_id}/comments", tags=["comments"])


@router.post("", response_model=CommentOut, status_code=201)
def create_comment(
    task_id: uuid.UUID,
    data: CommentCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> CommentOut:
    comment = comments_service.create_comment(db, org_id, current_user, task_id, data.body)
    return CommentOut.model_validate(comment)


@router.get("", response_model=list[CommentOut])
def list_comments(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[CommentOut]:
    comments = comments_service.list_comments(db, org_id, current_user, task_id)
    return [CommentOut.model_validate(c) for c in comments]
