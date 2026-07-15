"""Import all models here so SQLAlchemy's mapper configuration and Alembic's
autogenerate can discover them via a single entrypoint."""

from app.models.audit_log import AuditLog
from app.models.calendar_event import CalendarEvent
from app.models.collaboration import Attachment, Comment
from app.models.export_job import ExportJob
from app.models.notification import Notification
from app.models.organization import Organization
from app.models.project import Project, ProjectMember
from app.models.task import Task, TaskDependency
from app.models.task_activity import TaskActivityLog
from app.models.user import User
from app.models.worklog import WorkLog

__all__ = [
    "AuditLog",
    "CalendarEvent",
    "Attachment",
    "Comment",
    "ExportJob",
    "Notification",
    "Organization",
    "Project",
    "ProjectMember",
    "Task",
    "TaskActivityLog",
    "TaskDependency",
    "User",
    "WorkLog",
]
