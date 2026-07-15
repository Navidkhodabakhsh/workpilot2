import uuid
from datetime import date

from sqlalchemy import Date, Enum, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base_class import Base, TimestampMixin, UUIDPKMixin
from app.models.enums import ApprovalStatus, TaskPriority, TaskStatus


class Task(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "tasks"

    # Denormalized from project.organization_id on purpose — defense-in-depth
    # tenant scoping (see docs/ARCHITECTURE.md). Always set equal to
    # project.organization_id by the service layer, never taken from client input.
    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id"), nullable=False, index=True
    )
    # Nullable: a task with no project is a "personal task" (see
    # docs/ARCHITECTURE.md) -- it must have assignee_id == created_by_id,
    # enforced in the service layer.
    project_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("projects.id"), nullable=True, index=True
    )
    parent_task_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=True, index=True
    )
    assignee_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True, index=True
    )
    created_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))

    title: Mapped[str] = mapped_column(String(300), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    priority: Mapped[TaskPriority] = mapped_column(
        Enum(TaskPriority), nullable=False, default=TaskPriority.medium
    )
    status: Mapped[TaskStatus] = mapped_column(Enum(TaskStatus), nullable=False, default=TaskStatus.todo)
    # Independent of `status` on purpose -- a task can be Completed but still
    # Pending approval (see docs/ARCHITECTURE.md). Null until first submitted.
    approval_status: Mapped[ApprovalStatus | None] = mapped_column(Enum(ApprovalStatus), nullable=True)
    progress_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    estimated_hours: Mapped[float | None] = mapped_column(Numeric(6, 2), nullable=True)
    deadline: Mapped[date | None] = mapped_column(Date, nullable=True)

    project: Mapped["Project"] = relationship(back_populates="tasks")
    subtasks: Mapped[list["Task"]] = relationship(
        back_populates="parent_task", cascade="all, delete-orphan"
    )
    parent_task: Mapped["Task"] = relationship(back_populates="subtasks", remote_side="Task.id")


class TaskDependency(UUIDPKMixin, TimestampMixin, Base):
    """task_id depends on depends_on_task_id (task_id cannot start/finish until the other is done).

    Cycle detection is enforced in the service layer (app/services/tasks.py),
    not at the database level, since a CHECK/FK constraint cannot express
    "no cycle in this graph".
    """

    __tablename__ = "task_dependencies"

    task_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True
    )
    depends_on_task_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True
    )
