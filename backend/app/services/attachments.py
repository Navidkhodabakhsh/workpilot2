import os
import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.collaboration import Attachment
from app.models.enums import UserRole
from app.models.task import Task
from app.models.user import User
from app.services import finance as finance_service
from app.services.dashboard import get_visible_project_ids
from app.services.projects import assert_can_manage_project, get_project
from app.services.task_activity import log_task_activity
from app.services.tasks import get_task


def _to_dict(attachment: Attachment, uploaded_by_full_name: str) -> dict:
    return {
        "id": attachment.id,
        "task_id": attachment.task_id,
        "finance_entry_id": attachment.finance_entry_id,
        "uploaded_by_id": attachment.uploaded_by_id,
        "uploaded_by_full_name": uploaded_by_full_name,
        "original_filename": attachment.original_filename,
        "content_type": attachment.content_type,
        "size_bytes": attachment.size_bytes,
        "created_at": attachment.created_at,
    }


def _sanitize_filename(filename: str) -> str:
    # The client-supplied filename must never be trusted as a path
    # component: strip it down to its final segment so "../../etc/cron.d/x"
    # (or a Windows-style "..\\..\\x") can't escape the org's attachment
    # directory when it's joined into the storage path below.
    return os.path.basename(filename.replace("\\", "/")).strip() or "file"


def _save_upload(org_id: uuid.UUID, filename: str, content_type: str, contents: bytes) -> Attachment:
    if len(contents) > settings.max_attachment_size_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File exceeds the {settings.max_attachment_size_bytes // (1024 * 1024)}MB limit",
        )

    safe_filename = _sanitize_filename(filename)
    org_dir = os.path.join(settings.attachments_dir, str(org_id))
    os.makedirs(org_dir, exist_ok=True)
    stored_name = f"{uuid.uuid4()}-{safe_filename}"
    file_path = os.path.join(org_dir, stored_name)
    with open(file_path, "wb") as f:
        f.write(contents)

    return Attachment(
        organization_id=org_id,
        file_path=file_path,
        original_filename=safe_filename,
        content_type=content_type or "application/octet-stream",
        size_bytes=len(contents),
    )


def upload_attachment(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    task_id: uuid.UUID,
    filename: str,
    content_type: str,
    contents: bytes,
) -> dict:
    get_task(db, org_id, current_user, task_id)  # enforces view access

    attachment = _save_upload(org_id, filename, content_type, contents)
    attachment.task_id = task_id
    attachment.uploaded_by_id = current_user.id
    db.add(attachment)
    db.flush()

    log_task_activity(
        db, org_id, task_id, current_user.id, "task.attachment", {"filename": filename, "attachment_id": str(attachment.id)}
    )

    db.commit()
    db.refresh(attachment)
    return _to_dict(attachment, current_user.full_name)


def upload_finance_attachment(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    entry_id: uuid.UUID,
    filename: str,
    content_type: str,
    contents: bytes,
) -> dict:
    finance_service.assert_finance_access(current_user)
    finance_service.get_entry(db, org_id, entry_id)  # 404s if missing/foreign

    attachment = _save_upload(org_id, filename, content_type, contents)
    attachment.finance_entry_id = entry_id
    attachment.uploaded_by_id = current_user.id
    db.add(attachment)
    db.commit()
    db.refresh(attachment)
    return _to_dict(attachment, current_user.full_name)


def list_attachments_for_finance_entry(
    db: Session, org_id: uuid.UUID, current_user: User, entry_id: uuid.UUID
) -> list[dict]:
    finance_service.assert_finance_access(current_user)
    finance_service.get_entry(db, org_id, entry_id)  # 404s if missing/foreign
    rows = (
        db.query(Attachment, User.full_name)
        .join(User, Attachment.uploaded_by_id == User.id)
        .filter(Attachment.organization_id == org_id, Attachment.finance_entry_id == entry_id)
        .order_by(Attachment.created_at.desc())
        .all()
    )
    return [_to_dict(a, full_name) for a, full_name in rows]


def list_attachments_for_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> list[dict]:
    get_task(db, org_id, current_user, task_id)  # enforces view access
    rows = (
        db.query(Attachment, User.full_name)
        .join(User, Attachment.uploaded_by_id == User.id)
        .filter(Attachment.organization_id == org_id, Attachment.task_id == task_id)
        .order_by(Attachment.created_at.desc())
        .all()
    )
    return [_to_dict(a, full_name) for a, full_name in rows]


def list_attachments_for_org(db: Session, org_id: uuid.UUID, current_user: User) -> list[dict]:
    project_ids = get_visible_project_ids(db, org_id, current_user)
    if not project_ids:
        return []

    rows = (
        db.query(Attachment, User.full_name, Task.title, Task.project_id)
        .join(User, Attachment.uploaded_by_id == User.id)
        .join(Task, Attachment.task_id == Task.id)
        .filter(Attachment.organization_id == org_id, Task.project_id.in_(project_ids))
        .order_by(Attachment.created_at.desc())
        .all()
    )
    return [
        {**_to_dict(a, full_name), "task_title": task_title, "project_id": project_id}
        for a, full_name, task_title, project_id in rows
    ]


def get_attachment(db: Session, org_id: uuid.UUID, current_user: User, attachment_id: uuid.UUID) -> Attachment:
    attachment = (
        db.query(Attachment)
        .filter(Attachment.organization_id == org_id, Attachment.id == attachment_id)
        .first()
    )
    if attachment is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Attachment not found")
    if attachment.finance_entry_id is not None:
        finance_service.assert_finance_access(current_user)
    else:
        get_task(db, org_id, current_user, attachment.task_id)  # enforces view access
    return attachment


def delete_attachment(db: Session, org_id: uuid.UUID, current_user: User, attachment_id: uuid.UUID) -> None:
    attachment = get_attachment(db, org_id, current_user, attachment_id)

    if attachment.finance_entry_id is None and attachment.uploaded_by_id != current_user.id and current_user.role != UserRole.org_admin:
        task = get_task(db, org_id, current_user, attachment.task_id)
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_manage_project(db, project, current_user)

    if os.path.exists(attachment.file_path):
        os.remove(attachment.file_path)

    db.delete(attachment)
    db.commit()
