"""allow attachments on finance entries

Revision ID: d3e6f9a2b5c7
Revises: c2d5e8f1a4b6
Create Date: 2026-07-21 13:00:00.000000
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "d3e6f9a2b5c7"
down_revision: Union[str, None] = "c2d5e8f1a4b6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column("attachments", "task_id", nullable=True)
    op.add_column("attachments", sa.Column("finance_entry_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.create_index(op.f("ix_attachments_finance_entry_id"), "attachments", ["finance_entry_id"])
    op.create_foreign_key(
        "fk_attachments_finance_entry_id_finance_entries",
        "attachments",
        "finance_entries",
        ["finance_entry_id"],
        ["id"],
    )
    op.create_check_constraint(
        "ck_attachment_exactly_one_parent",
        "attachments",
        "(task_id IS NOT NULL AND finance_entry_id IS NULL) OR "
        "(task_id IS NULL AND finance_entry_id IS NOT NULL)",
    )


def downgrade() -> None:
    op.drop_constraint("ck_attachment_exactly_one_parent", "attachments", type_="check")
    op.drop_constraint("fk_attachments_finance_entry_id_finance_entries", "attachments", type_="foreignkey")
    op.drop_index(op.f("ix_attachments_finance_entry_id"), "attachments")
    op.drop_column("attachments", "finance_entry_id")
    op.alter_column("attachments", "task_id", nullable=False)
