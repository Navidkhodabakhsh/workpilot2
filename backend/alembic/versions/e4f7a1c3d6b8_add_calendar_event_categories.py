"""add calendar event categories

Revision ID: e4f7a1c3d6b8
Revises: d3e6f9a2b5c7
Create Date: 2026-07-21 14:00:00.000000
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "e4f7a1c3d6b8"
down_revision: Union[str, None] = "d3e6f9a2b5c7"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "calendar_event_categories",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("color", sa.String(length=20), nullable=False, server_default="#64748b"),
        sa.Column("is_system", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.ForeignKeyConstraint(["organization_id"], ["organizations.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("organization_id", "name", name="uq_calendar_event_category_org_name"),
    )
    op.create_index(
        op.f("ix_calendar_event_categories_organization_id"), "calendar_event_categories", ["organization_id"]
    )

    op.add_column("calendar_events", sa.Column("category_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.create_index(op.f("ix_calendar_events_category_id"), "calendar_events", ["category_id"])
    op.create_foreign_key(
        "fk_calendar_events_category_id_calendar_event_categories",
        "calendar_events",
        "calendar_event_categories",
        ["category_id"],
        ["id"],
    )


def downgrade() -> None:
    op.drop_constraint(
        "fk_calendar_events_category_id_calendar_event_categories", "calendar_events", type_="foreignkey"
    )
    op.drop_index(op.f("ix_calendar_events_category_id"), "calendar_events")
    op.drop_column("calendar_events", "category_id")

    op.drop_index(op.f("ix_calendar_event_categories_organization_id"), "calendar_event_categories")
    op.drop_table("calendar_event_categories")
