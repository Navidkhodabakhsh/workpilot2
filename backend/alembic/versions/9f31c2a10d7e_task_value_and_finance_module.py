"""add task business value and finance ledger

Revision ID: 9f31c2a10d7e
Revises: 6b99afe0a3a4
Create Date: 2026-07-20 14:30:00.000000
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql


revision: str = "9f31c2a10d7e"
down_revision: Union[str, None] = "6b99afe0a3a4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    task_value = postgresql.ENUM("low", "medium", "high", name="taskvalue")
    task_value.create(op.get_bind())
    op.add_column(
        "tasks",
        sa.Column("value", task_value, nullable=False, server_default="medium"),
    )
    op.alter_column("tasks", "value", server_default=None)

    finance_type = postgresql.ENUM("income", "expense", name="financeentrytype")
    finance_type.create(op.get_bind())
    finance_type_ref = postgresql.ENUM(
        "income", "expense", name="financeentrytype", create_type=False
    )

    op.create_table(
        "finance_categories",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column(
            "organization_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("organizations.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("entry_type", finance_type_ref, nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("color", sa.String(length=20), nullable=False, server_default="#64748b"),
        sa.Column("is_system", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.UniqueConstraint(
            "organization_id", "entry_type", "name", name="uq_finance_category_org_type_name"
        ),
    )
    op.create_index("ix_finance_categories_organization_id", "finance_categories", ["organization_id"])
    op.create_index("ix_finance_categories_entry_type", "finance_categories", ["entry_type"])

    op.create_table(
        "finance_entries",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column(
            "organization_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("organizations.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("category_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("finance_categories.id"), nullable=False),
        sa.Column("project_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("projects.id"), nullable=True),
        sa.Column("recorded_by_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("entry_type", finance_type_ref, nullable=False),
        sa.Column("document_date", sa.Date(), nullable=False),
        sa.Column("amount", sa.Numeric(16, 2), nullable=False),
        sa.Column("title", sa.String(length=240), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("document_number", sa.String(length=100), nullable=True),
        sa.Column("counterparty", sa.String(length=200), nullable=True),
    )
    op.create_index("ix_finance_entries_organization_id", "finance_entries", ["organization_id"])
    op.create_index("ix_finance_entries_category_id", "finance_entries", ["category_id"])
    op.create_index("ix_finance_entries_project_id", "finance_entries", ["project_id"])
    op.create_index("ix_finance_entries_entry_type", "finance_entries", ["entry_type"])
    op.create_index("ix_finance_entries_document_date", "finance_entries", ["document_date"])


def downgrade() -> None:
    op.drop_index("ix_finance_entries_document_date", table_name="finance_entries")
    op.drop_index("ix_finance_entries_entry_type", table_name="finance_entries")
    op.drop_index("ix_finance_entries_project_id", table_name="finance_entries")
    op.drop_index("ix_finance_entries_category_id", table_name="finance_entries")
    op.drop_index("ix_finance_entries_organization_id", table_name="finance_entries")
    op.drop_table("finance_entries")
    op.drop_index("ix_finance_categories_entry_type", table_name="finance_categories")
    op.drop_index("ix_finance_categories_organization_id", table_name="finance_categories")
    op.drop_table("finance_categories")
    op.execute("DROP TYPE financeentrytype")
    op.drop_column("tasks", "value")
    op.execute("DROP TYPE taskvalue")
