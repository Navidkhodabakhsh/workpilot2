"""add department memberships

Revision ID: 6b99afe0a3a4
Revises: 60291deba722
Create Date: 2026-07-20 09:41:56.343152

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = '6b99afe0a3a4'
down_revision: Union[str, None] = '60291deba722'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Reuses the existing "userrole" enum type (created for users.role) --
    # create_type=False so this column doesn't attempt to CREATE TYPE again.
    user_role_enum = postgresql.ENUM(
        "platform_admin", "org_admin", "project_manager", "employee", name="userrole", create_type=False
    )

    op.create_table(
        "department_memberships",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("organization_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("organizations.id"), nullable=False),
        sa.Column(
            "user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False
        ),
        sa.Column(
            "department_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("departments.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", user_role_enum, nullable=False),
        sa.UniqueConstraint("user_id", "department_id", name="uq_department_membership_user_department"),
    )
    op.create_index("ix_department_memberships_organization_id", "department_memberships", ["organization_id"])
    op.create_index("ix_department_memberships_user_id", "department_memberships", ["user_id"])
    op.create_index("ix_department_memberships_department_id", "department_memberships", ["department_id"])

    # Backfill: every existing project_manager/employee with a department
    # already set becomes a member of that one department, at their
    # existing role -- User.department_id/.role stay as the "primary"
    # values (still used everywhere they already were); this table is the
    # additional memberships beyond that.
    op.execute(
        """
        INSERT INTO department_memberships (id, organization_id, user_id, department_id, role, created_at, updated_at)
        SELECT gen_random_uuid(), organization_id, id, department_id, role, now(), now()
        FROM users
        WHERE department_id IS NOT NULL AND role IN ('project_manager', 'employee')
        """
    )


def downgrade() -> None:
    op.drop_index("ix_department_memberships_department_id", table_name="department_memberships")
    op.drop_index("ix_department_memberships_user_id", table_name="department_memberships")
    op.drop_index("ix_department_memberships_organization_id", table_name="department_memberships")
    op.drop_table("department_memberships")
