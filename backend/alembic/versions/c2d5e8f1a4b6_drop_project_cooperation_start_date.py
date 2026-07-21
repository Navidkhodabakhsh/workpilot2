"""drop redundant project.cooperation_start_date

Revision ID: c2d5e8f1a4b6
Revises: b1c4d7e9f2a3
Create Date: 2026-07-21 10:00:00.000000
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


revision: str = "c2d5e8f1a4b6"
down_revision: Union[str, None] = "b1c4d7e9f2a3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column("projects", "cooperation_start_date")


def downgrade() -> None:
    op.add_column("projects", sa.Column("cooperation_start_date", sa.Date(), nullable=True))
