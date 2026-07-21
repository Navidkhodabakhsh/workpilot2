"""Import all models here so SQLAlchemy's mapper configuration and Alembic's
autogenerate can discover them via a single entrypoint."""

from app.models.account import Account
from app.models.audit_log import AuditLog
from app.models.calendar_event import CalendarEvent
from app.models.collaboration import Attachment, Comment
from app.models.department import Department
from app.models.department_membership import DepartmentMembership
from app.models.export_job import ExportJob
from app.models.finance import FinanceCategory, FinanceEntry
from app.models.leave_request import LeaveRequest
from app.models.notification import Notification
from app.models.organization import Organization
from app.models.otp_code import OtpCode
from app.models.payment import Payment
from app.models.project import Project, ProjectMember
from app.models.task import Task, TaskDependency
from app.models.task_activity import TaskActivityLog
from app.models.user import User
from app.models.worklog import WorkLog

__all__ = [
    "Account",
    "AuditLog",
    "CalendarEvent",
    "Attachment",
    "Comment",
    "Department",
    "DepartmentMembership",
    "ExportJob",
    "FinanceCategory",
    "FinanceEntry",
    "LeaveRequest",
    "Notification",
    "Organization",
    "OtpCode",
    "Payment",
    "Project",
    "ProjectMember",
    "Task",
    "TaskActivityLog",
    "TaskDependency",
    "User",
    "WorkLog",
]
