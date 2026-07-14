import enum


class UserRole(str, enum.Enum):
    platform_admin = "platform_admin"
    org_admin = "org_admin"
    project_manager = "project_manager"
    employee = "employee"


class ProjectStatus(str, enum.Enum):
    active = "active"
    completed = "completed"
    archived = "archived"


class TaskPriority(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"


class TaskStatus(str, enum.Enum):
    todo = "todo"
    in_progress = "in_progress"
    in_review = "in_review"
    done = "done"
    blocked = "blocked"


class WorkLogStatus(str, enum.Enum):
    draft = "draft"
    submitted = "submitted"
    approved = "approved"
    rejected = "rejected"


class NotificationType(str, enum.Enum):
    task_created = "task_created"
    deadline_approaching = "deadline_approaching"
    report_submitted = "report_submitted"
    report_reviewed = "report_reviewed"


class ExportFileType(str, enum.Enum):
    excel = "excel"
    pdf = "pdf"
    csv = "csv"


class ExportJobStatus(str, enum.Enum):
    pending = "pending"
    processing = "processing"
    done = "done"
    failed = "failed"
