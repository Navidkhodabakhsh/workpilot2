"""add signup value to otppurpose enum

Revision ID: f6a9c2d5e8b1
Revises: e4f7a1c3d6b8
Create Date: 2026-07-22 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op

# revision identifiers, used by Alembic.
revision: str = 'f6a9c2d5e8b1'
down_revision: Union[str, None] = 'e4f7a1c3d6b8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TYPE otppurpose ADD VALUE 'signup'")


def downgrade() -> None:
    # Postgres can't drop a single enum value in place -- rebuilding the
    # type would require rewriting otp_codes.purpose, and any 'signup' rows
    # would need to be dealt with first. Not needed in practice: this is
    # additive-only and never targeted by a downgrade in this project.
    pass
