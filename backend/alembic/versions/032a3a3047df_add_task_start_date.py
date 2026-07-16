"""add task start_date

Revision ID: 032a3a3047df
Revises: ee822a986fe7
Create Date: 2026-07-16 13:14:48.565780

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '032a3a3047df'
down_revision: Union[str, None] = 'ee822a986fe7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("tasks", sa.Column("start_date", sa.Date(), nullable=True))


def downgrade() -> None:
    op.drop_column("tasks", "start_date")
