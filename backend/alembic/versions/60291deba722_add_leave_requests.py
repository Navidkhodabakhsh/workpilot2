"""add leave requests

Revision ID: 60291deba722
Revises: 734190b6fd34
Create Date: 2026-07-16 14:30:51.234459

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = '60291deba722'
down_revision: Union[str, None] = '734190b6fd34'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'leave_reviewed'")

    # Reuses the existing "approvalstatus" enum type (created for tasks) --
    # create_type=False so this column doesn't attempt to CREATE TYPE again.
    approval_status_enum = postgresql.ENUM(
        "pending", "approved", "rejected", name="approvalstatus", create_type=False
    )

    op.create_table(
        "leave_requests",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("organizations.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("start_date", sa.Date(), nullable=False),
        sa.Column("end_date", sa.Date(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("status", approval_status_enum, nullable=False, server_default="pending"),
        sa.Column(
            "reviewed_by_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("review_comment", sa.Text(), nullable=True),
    )
    op.create_index("ix_leave_requests_organization_id", "leave_requests", ["organization_id"])
    op.create_index("ix_leave_requests_user_id", "leave_requests", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_leave_requests_user_id", table_name="leave_requests")
    op.drop_index("ix_leave_requests_organization_id", table_name="leave_requests")
    op.drop_table("leave_requests")
    # Postgres cannot drop a single enum value -- same rationale as the
    # comment_added migration (67a93e70f708).
