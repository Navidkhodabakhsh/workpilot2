"""add calendar_events table and event_reminder notification type

Revision ID: 5caf58e16e40
Revises: 04da1673aa0f
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '5caf58e16e40'
down_revision: Union[str, None] = '04da1673aa0f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'event_reminder'")

    # Don't call .create() separately -- create_table() below already issues
    # CREATE TYPE for this enum column; doing both raises DuplicateObject.
    calendar_event_type_enum = postgresql.ENUM(
        "meeting", "leave", "holiday", "reminder", name="calendareventtype"
    )

    op.create_table(
        "calendar_events",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("organizations.id"), nullable=False),
        sa.Column("created_by_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("project_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("projects.id"), nullable=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True),
        sa.Column("title", sa.String(length=300), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("event_type", calendar_event_type_enum, nullable=False),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("all_day", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.create_index("ix_calendar_events_organization_id", "calendar_events", ["organization_id"])
    op.create_index("ix_calendar_events_project_id", "calendar_events", ["project_id"])
    op.create_index("ix_calendar_events_user_id", "calendar_events", ["user_id"])
    op.create_index("ix_calendar_events_start_at", "calendar_events", ["start_at"])


def downgrade() -> None:
    op.drop_index("ix_calendar_events_start_at", table_name="calendar_events")
    op.drop_index("ix_calendar_events_user_id", table_name="calendar_events")
    op.drop_index("ix_calendar_events_project_id", table_name="calendar_events")
    op.drop_index("ix_calendar_events_organization_id", table_name="calendar_events")
    op.drop_table("calendar_events")
    op.execute("DROP TYPE calendareventtype")
    # Postgres cannot drop a single enum value -- same rationale as the
    # comment_added migration (67a93e70f708).
