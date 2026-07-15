import uuid
from datetime import datetime

from pydantic import BaseModel


class AttachmentOut(BaseModel):
    id: uuid.UUID
    task_id: uuid.UUID
    uploaded_by_id: uuid.UUID
    uploaded_by_full_name: str
    original_filename: str
    content_type: str
    size_bytes: int
    created_at: datetime
    # Only populated by the org-wide listing (GET /attachments), which joins
    # Task; the per-task listing omits these since the caller already knows
    # which task/project they're looking at.
    task_title: str | None = None
    project_id: uuid.UUID | None = None

    model_config = {"from_attributes": True}
