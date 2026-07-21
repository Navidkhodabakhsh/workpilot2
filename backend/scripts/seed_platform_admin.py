"""One-off script to create the first platform_admin account.

platform_admin is not tied to any organization and cannot be created through
the public /auth/signup endpoint (which always creates a new organization
plus an org_admin). Run this once per deployment:

    python -m scripts.seed_platform_admin --phone 09120000000 --password '...'
"""

import argparse
import sys

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.account import Account
from app.models.enums import UserRole
from app.models.user import User


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed the first platform_admin user")
    parser.add_argument("--phone", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--full-name", default="Platform Admin")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        existing = db.query(Account).filter(Account.phone_number == args.phone).first()
        if existing is not None:
            print(f"An account with phone number {args.phone} already exists.", file=sys.stderr)
            sys.exit(1)

        account = Account(phone_number=args.phone, hashed_password=hash_password(args.password))
        db.add(account)
        db.flush()

        admin = User(
            account_id=account.id,
            organization_id=None,
            full_name=args.full_name,
            role=UserRole.platform_admin,
        )
        db.add(admin)
        db.commit()
        print(f"Created platform_admin user: {args.phone}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
