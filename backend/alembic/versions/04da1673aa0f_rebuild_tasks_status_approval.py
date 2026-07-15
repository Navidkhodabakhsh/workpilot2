"""rebuild tasks: 4-value status, approval_status, progress/estimate, personal tasks, activity log

Revision ID: 04da1673aa0f
Revises: 5b4dbfab694a
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '04da1673aa0f'
down_revision: Union[str, None] = '5b4dbfab694a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- TaskStatus: 5 values -> 4 values (todo/in_progress/completed/archived) ---
    # Postgres cannot rename/remove enum labels in place while old rows still
    # use them, so: build the new type, backfill through a temp column, then
    # swap it in and drop the old type.
    op.execute("CREATE TYPE taskstatus_new AS ENUM ('todo', 'in_progress', 'completed', 'archived')")
    op.add_column("tasks", sa.Column("status_new", sa.Enum(
        "todo", "in_progress", "completed", "archived", name="taskstatus_new"
    ), nullable=True))
    op.execute(
        """
        UPDATE tasks SET status_new = (
            CASE status::text
                WHEN 'in_review' THEN 'in_progress'
                WHEN 'blocked' THEN 'todo'
                WHEN 'done' THEN 'completed'
                ELSE status::text
            END
        )::taskstatus_new
        """
    )
    op.alter_column("tasks", "status_new", nullable=False)
    op.drop_column("tasks", "status")
    op.execute("ALTER TYPE taskstatus_new RENAME TO taskstatus_old_swap")
    op.alter_column("tasks", "status_new", new_column_name="status")
    op.execute("DROP TYPE taskstatus")
    op.execute("ALTER TYPE taskstatus_old_swap RENAME TO taskstatus")

    # --- New independent ApprovalStatus enum + column ---
    approval_status_enum = postgresql.ENUM("pending", "approved", "rejected", name="approvalstatus")
    approval_status_enum.create(op.get_bind())
    op.add_column("tasks", sa.Column("approval_status", approval_status_enum, nullable=True))

    # --- progress_percent / estimated_hours ---
    op.add_column("tasks", sa.Column("progress_percent", sa.Integer(), nullable=False, server_default="0"))
    op.alter_column("tasks", "progress_percent", server_default=None)
    op.add_column("tasks", sa.Column("estimated_hours", sa.Numeric(6, 2), nullable=True))

    # --- project_id becomes nullable (personal tasks) ---
    op.alter_column("tasks", "project_id", nullable=True)

    # --- task_activity_logs ---
    op.create_table(
        "task_activity_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("organizations.id"), nullable=False),
        sa.Column("task_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("tasks.id"), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("action", sa.String(length=100), nullable=False),
        sa.Column("extra_metadata", postgresql.JSONB(), nullable=False, server_default="{}"),
    )
    op.create_index("ix_task_activity_logs_organization_id", "task_activity_logs", ["organization_id"])
    op.create_index("ix_task_activity_logs_task_id", "task_activity_logs", ["task_id"])


def downgrade() -> None:
    op.drop_index("ix_task_activity_logs_task_id", table_name="task_activity_logs")
    op.drop_index("ix_task_activity_logs_organization_id", table_name="task_activity_logs")
    op.drop_table("task_activity_logs")

    op.alter_column("tasks", "project_id", nullable=False)

    op.drop_column("tasks", "estimated_hours")
    op.drop_column("tasks", "progress_percent")

    op.drop_column("tasks", "approval_status")
    op.execute("DROP TYPE approvalstatus")

    op.execute("CREATE TYPE taskstatus_old AS ENUM ('todo', 'in_progress', 'in_review', 'done', 'blocked')")
    op.add_column("tasks", sa.Column("status_old", sa.Enum(
        "todo", "in_progress", "in_review", "done", "blocked", name="taskstatus_old"
    ), nullable=True))
    op.execute(
        """
        UPDATE tasks SET status_old = (
            CASE status::text
                WHEN 'completed' THEN 'done'
                WHEN 'archived' THEN 'blocked'
                ELSE status::text
            END
        )::taskstatus_old
        """
    )
    op.alter_column("tasks", "status_old", nullable=False)
    op.drop_column("tasks", "status")
    op.execute("ALTER TYPE taskstatus_old RENAME TO taskstatus_new_swap")
    op.alter_column("tasks", "status_old", new_column_name="status")
    op.execute("DROP TYPE taskstatus")
    op.execute("ALTER TYPE taskstatus_new_swap RENAME TO taskstatus")
