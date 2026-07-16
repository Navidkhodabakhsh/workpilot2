"""add departments

Revision ID: 734190b6fd34
Revises: 032a3a3047df
Create Date: 2026-07-16 13:38:49.796463

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = '734190b6fd34'
down_revision: Union[str, None] = '032a3a3047df'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "departments",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("organizations.id"), nullable=False),
        sa.Column("name", sa.String(length=200), nullable=False),
    )
    op.create_index("ix_departments_organization_id", "departments", ["organization_id"])

    # Nullable on purpose: existing rows (and any org created before this
    # migration) have no department to backfill into. Only new signups are
    # required to pick one -- see services/auth.py::signup.
    op.add_column("users", sa.Column("department_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.create_foreign_key(
        "fk_users_department_id_departments", "users", "departments", ["department_id"], ["id"], ondelete="SET NULL"
    )
    op.add_column("projects", sa.Column("department_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.create_foreign_key(
        "fk_projects_department_id_departments",
        "projects",
        "departments",
        ["department_id"],
        ["id"],
        ondelete="SET NULL",
    )


def downgrade() -> None:
    op.drop_constraint("fk_projects_department_id_departments", "projects", type_="foreignkey")
    op.drop_column("projects", "department_id")
    op.drop_constraint("fk_users_department_id_departments", "users", type_="foreignkey")
    op.drop_column("users", "department_id")
    op.drop_index("ix_departments_organization_id", table_name="departments")
    op.drop_table("departments")
