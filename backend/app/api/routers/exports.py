import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import ExportFileType, ExportJobStatus
from app.models.user import User
from app.schemas.export import ExportJobCreate, ExportJobOut
from app.services import exports as exports_service

router = APIRouter(prefix="/exports", tags=["exports"])

_MEDIA_TYPES = {
    ExportFileType.csv: "text/csv",
    ExportFileType.excel: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ExportFileType.pdf: "application/pdf",
}


def _to_out(job) -> ExportJobOut:
    return ExportJobOut(
        id=job.id,
        export_type=job.export_type,
        status=job.status,
        error_message=job.error_message,
        created_at=job.created_at,
        completed_at=job.completed_at,
        download_available=job.status == ExportJobStatus.done and bool(job.file_path),
    )


@router.post("", response_model=ExportJobOut, status_code=201)
def create_export(
    data: ExportJobCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ExportJobOut:
    job = exports_service.create_export_job(db, org_id, current_user, data)
    return _to_out(job)


@router.get("/{job_id}", response_model=ExportJobOut)
def get_export(
    job_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ExportJobOut:
    job = exports_service.get_export_job(db, org_id, current_user, job_id)
    return _to_out(job)


@router.get("/{job_id}/download")
def download_export(
    job_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> FileResponse:
    job = exports_service.get_export_job(db, org_id, current_user, job_id)
    if job.status != ExportJobStatus.done or not job.file_path:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Export is not ready yet")

    extension = {"excel": "xlsx", "pdf": "pdf", "csv": "csv"}[job.export_type.value]
    return FileResponse(
        job.file_path,
        media_type=_MEDIA_TYPES[job.export_type],
        filename=f"workpilot-report-{job.id}.{extension}",
    )
