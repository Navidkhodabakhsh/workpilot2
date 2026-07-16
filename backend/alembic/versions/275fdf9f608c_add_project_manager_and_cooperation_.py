"""add project manager and cooperation start date

Revision ID: 275fdf9f608c
Revises: a943e0a49f2e
Create Date: 2026-07-16 11:44:13.420295

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = '275fdf9f608c'
down_revision: Union[str, None] = 'a943e0a49f2e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("projects", sa.Column("manager_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("projects", sa.Column("cooperation_start_date", sa.Date(), nullable=True))
    op.create_foreign_key(
        "fk_projects_manager_id_users", "projects", "users", ["manager_id"], ["id"], ondelete="SET NULL"
    )


def downgrade() -> None:
    op.drop_constraint("fk_projects_manager_id_users", "projects", type_="foreignkey")
    op.drop_column("projects", "cooperation_start_date")
    op.drop_column("projects", "manager_id")
