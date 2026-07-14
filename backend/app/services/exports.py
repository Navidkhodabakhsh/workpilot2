import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import ExportJobStatus, UserRole
from app.models.export_job import ExportJob
from app.models.user import User
from app.schemas.export import ExportJobCreate
from app.services.projects import assert_can_view_project, get_project


class ExportJobRepository(TenantScopedRepository[ExportJob]):
    model = ExportJob


def create_export_job(db: Session, org_id: uuid.UUID, current_user: User, data: ExportJobCreate) -> ExportJob:
    # Fail fast on an inaccessible project rather than silently queuing a job
    # that would produce an empty file.
    if data.project_id is not None:
        project = get_project(db, org_id, current_user, data.project_id)
        assert_can_view_project(db, project, current_user)

    filters = {
        "project_id": str(data.project_id) if data.project_id else None,
        "user_id": str(data.user_id) if data.user_id else None,
        "status_filter": data.status_filter,
        "date_from": data.date_from.isoformat() if data.date_from else None,
        "date_to": data.date_to.isoformat() if data.date_to else None,
    }

    job = ExportJob(
        organization_id=org_id,
        requested_by_id=current_user.id,
        export_type=data.export_type,
        filters=filters,
        status=ExportJobStatus.pending,
    )
    db.add(job)
    db.commit()
    db.refresh(job)

    # Imported lazily to avoid the API process importing Celery's worker
    # bootstrap machinery unless it's actually needed.
    from app.workers.tasks import generate_export

    generate_export.delay(str(job.id))

    return job


def get_export_job(db: Session, org_id: uuid.UUID, current_user: User, job_id: uuid.UUID) -> ExportJob:
    job = ExportJobRepository(db, org_id).get(job_id)
    if job is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Export job not found")
    # A job may aggregate data across projects/users beyond what the
    # requester's role would otherwise see filtered per-project, so only the
    # requester themself or an org_admin may read it back -- not "any org member".
    if current_user.role != UserRole.org_admin and job.requested_by_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You cannot access this export job")
    return job
