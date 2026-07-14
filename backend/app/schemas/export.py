import uuid
from datetime import date, datetime

from pydantic import BaseModel

from app.models.enums import ExportFileType, ExportJobStatus


class ExportJobCreate(BaseModel):
    export_type: ExportFileType
    project_id: uuid.UUID | None = None
    user_id: uuid.UUID | None = None
    status_filter: str | None = None
    date_from: date | None = None
    date_to: date | None = None


class ExportJobOut(BaseModel):
    id: uuid.UUID
    export_type: ExportFileType
    status: ExportJobStatus
    error_message: str | None
    created_at: datetime
    completed_at: datetime | None
    download_available: bool

    model_config = {"from_attributes": True}
