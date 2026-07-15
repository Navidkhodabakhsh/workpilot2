"""add comment_added notification type

Revision ID: 67a93e70f708
Revises: 24ef455fdc1d
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op

# revision identifiers, used by Alembic.
revision: str = '67a93e70f708'
down_revision: Union[str, None] = '24ef455fdc1d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'comment_added'")


def downgrade() -> None:
    # Postgres cannot drop a single enum value; downgrading this migration
    # would require recreating the type and rewriting every dependent
    # column, which is unnecessary here (no data ever needs the value
    # removed, only added).
    pass
