"""split account identity from user org membership

Revision ID: b1c4d7e9f2a3
Revises: 9f31c2a10d7e
Create Date: 2026-07-21 09:00:00.000000
"""
import uuid
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql


revision: str = "b1c4d7e9f2a3"
down_revision: Union[str, None] = "9f31c2a10d7e"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "accounts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("phone_number", sa.String(32), nullable=False),
        sa.Column("hashed_password", sa.String(255), nullable=True),
    )
    op.create_index(op.f("ix_accounts_phone_number"), "accounts", ["phone_number"], unique=True)

    op.add_column("users", sa.Column("account_id", postgresql.UUID(as_uuid=True), nullable=True))

    # Backfill: one Account per existing users row, reusing its
    # phone_number/hashed_password. A legacy row with no phone_number (the
    # column allowed it) can't become the sole identity key, so it gets a
    # synthesized placeholder -- this only matters for pre-existing local/dev
    # data, not a fresh database.
    connection = op.get_bind()
    rows = connection.execute(sa.text("SELECT id, phone_number, hashed_password FROM users")).fetchall()
    for user_id, phone_number, hashed_password in rows:
        if phone_number is None:
            phone_number = f"unknown-{user_id}"
        account_id = uuid.uuid4()
        connection.execute(
            sa.text(
                "INSERT INTO accounts (id, phone_number, hashed_password, created_at, updated_at) "
                "VALUES (:id, :phone, :pwd, now(), now())"
            ),
            {"id": account_id, "phone": phone_number, "pwd": hashed_password},
        )
        connection.execute(
            sa.text("UPDATE users SET account_id = :aid WHERE id = :uid"),
            {"aid": account_id, "uid": user_id},
        )

    op.alter_column("users", "account_id", nullable=False)
    op.create_foreign_key("fk_users_account_id_accounts", "users", "accounts", ["account_id"], ["id"])
    op.create_index(op.f("ix_users_account_id"), "users", ["account_id"])
    op.create_unique_constraint("uq_user_account_organization", "users", ["account_id", "organization_id"])

    op.drop_index("ix_users_email", table_name="users")
    op.drop_column("users", "email")
    op.drop_index("ix_users_phone_number", table_name="users")
    op.drop_column("users", "phone_number")
    op.drop_column("users", "hashed_password")


def downgrade() -> None:
    op.add_column("users", sa.Column("email", sa.String(255), nullable=True))
    op.add_column("users", sa.Column("phone_number", sa.String(32), nullable=True))
    op.add_column("users", sa.Column("hashed_password", sa.String(255), nullable=True))

    connection = op.get_bind()
    rows = connection.execute(
        sa.text(
            "SELECT u.id, a.phone_number, a.hashed_password FROM users u "
            "JOIN accounts a ON a.id = u.account_id"
        )
    ).fetchall()
    for user_id, phone_number, hashed_password in rows:
        connection.execute(
            sa.text(
                "UPDATE users SET email = :email, phone_number = :phone, hashed_password = :pwd WHERE id = :uid"
            ),
            {
                "email": f"user-{user_id}@legacy.local",
                "phone": phone_number,
                "pwd": hashed_password,
                "uid": user_id,
            },
        )

    op.alter_column("users", "email", nullable=False)
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)
    op.create_index(op.f("ix_users_phone_number"), "users", ["phone_number"], unique=True)

    op.drop_constraint("uq_user_account_organization", "users", type_="unique")
    op.drop_index(op.f("ix_users_account_id"), table_name="users")
    op.drop_constraint("fk_users_account_id_accounts", "users", type_="foreignkey")
    op.drop_column("users", "account_id")

    op.drop_index(op.f("ix_accounts_phone_number"), table_name="accounts")
    op.drop_table("accounts")
