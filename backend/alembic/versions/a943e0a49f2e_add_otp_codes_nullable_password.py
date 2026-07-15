"""add otp_codes table, make hashed_password nullable

Revision ID: a943e0a49f2e
Revises: 5caf58e16e40
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'a943e0a49f2e'
down_revision: Union[str, None] = '5caf58e16e40'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column("users", "hashed_password", nullable=True)

    otp_purpose_enum = postgresql.ENUM("login", "password_reset", name="otppurpose")

    op.create_table(
        "otp_codes",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("phone_number", sa.String(length=32), nullable=False),
        sa.Column("code_hash", sa.String(length=255), nullable=False),
        sa.Column("purpose", otp_purpose_enum, nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("consumed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("attempt_count", sa.Integer(), nullable=False, server_default="0"),
    )
    op.create_index("ix_otp_codes_phone_number", "otp_codes", ["phone_number"])


def downgrade() -> None:
    op.drop_index("ix_otp_codes_phone_number", table_name="otp_codes")
    op.drop_table("otp_codes")
    op.execute("DROP TYPE otppurpose")
    op.alter_column("users", "hashed_password", nullable=False)
