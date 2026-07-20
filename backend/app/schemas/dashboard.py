import uuid

from pydantic import BaseModel


class StatusCount(BaseModel):
    status: str
    count: int


class TeamMemberHours(BaseModel):
    user_id: uuid.UUID
    full_name: str
    approved_hours: float
    percent: float


class ProjectHours(BaseModel):
    project_id: uuid.UUID
    project_name: str
    approved_hours: float
    percent: float


class RecentActivityItem(BaseModel):
    worklog_id: uuid.UUID
    task_id: uuid.UUID
    task_title: str
    user_id: uuid.UUID
    user_full_name: str
    status: str
    created_at: str


class DashboardSummary(BaseModel):
    project_count: int
    projects_by_status: list[StatusCount]
    task_count: int
    tasks_by_status: list[StatusCount]
    total_approved_hours: float
    team_hours: list[TeamMemberHours]
    project_hours: list[ProjectHours]
    recent_activity: list[RecentActivityItem]
