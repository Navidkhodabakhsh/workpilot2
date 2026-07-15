"""add user phone_number

Revision ID: 5b4dbfab694a
Revises: 67a93e70f708
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = '5b4dbfab694a'
down_revision: Union[str, None] = '67a93e70f708'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("phone_number", sa.String(length=32), nullable=True))
    op.create_index(op.f("ix_users_phone_number"), "users", ["phone_number"], unique=True)


def downgrade() -> None:
    op.drop_index(op.f("ix_users_phone_number"), table_name="users")
    op.drop_column("users", "phone_number")
