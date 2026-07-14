import uuid
from datetime import date, datetime

from pydantic import BaseModel

from app.models.enums import WorkLogStatus


class WorkLogReportRow(BaseModel):
    worklog_id: uuid.UUID
    task_id: uuid.UUID
    task_title: str
    project_id: uuid.UUID
    project_name: str
    user_id: uuid.UUID
    user_full_name: str
    activity_description: str
    time_spent_minutes: int
    progress_percent: int
    log_date: date
    status: WorkLogStatus
    created_at: datetime


class WorkLogReport(BaseModel):
    items: list[WorkLogReportRow]
    total_minutes: int
    total_hours: float
