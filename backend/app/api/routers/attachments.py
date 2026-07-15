import uuid

from fastapi import APIRouter, Depends, File, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.attachment import AttachmentOut
from app.services import attachments as attachments_service

task_attachments_router = APIRouter(prefix="/tasks/{task_id}/attachments", tags=["attachments"])
attachments_router = APIRouter(prefix="/attachments", tags=["attachments"])


@task_attachments_router.post("", response_model=AttachmentOut, status_code=201)
async def upload_attachment(
    task_id: uuid.UUID,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> AttachmentOut:
    contents = await file.read()
    attachment = attachments_service.upload_attachment(
        db, org_id, current_user, task_id, file.filename or "file", file.content_type or "", contents
    )
    return AttachmentOut.model_validate(attachment)


@task_attachments_router.get("", response_model=list[AttachmentOut])
def list_task_attachments(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[AttachmentOut]:
    attachments = attachments_service.list_attachments_for_task(db, org_id, current_user, task_id)
    return [AttachmentOut.model_validate(a) for a in attachments]


@attachments_router.get("", response_model=list[AttachmentOut])
def list_org_attachments(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[AttachmentOut]:
    attachments = attachments_service.list_attachments_for_org(db, org_id, current_user)
    return [AttachmentOut.model_validate(a) for a in attachments]


@attachments_router.get("/{attachment_id}/download")
def download_attachment(
    attachment_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FileResponse:
    attachment = attachments_service.get_attachment(db, org_id, current_user, attachment_id)
    return FileResponse(
        attachment.file_path, media_type=attachment.content_type, filename=attachment.original_filename
    )


@attachments_router.delete("/{attachment_id}", status_code=204)
def delete_attachment(
    attachment_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    attachments_service.delete_attachment(db, org_id, current_user, attachment_id)
