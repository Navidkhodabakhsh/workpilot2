"""One-off script to create the first platform_admin account.

platform_admin is not tied to any organization and cannot be created through
the public /auth/signup endpoint (which always creates a new organization
plus an org_admin). Run this once per deployment:

    python -m scripts.seed_platform_admin --email admin@workpilot.example --password '...'
"""

import argparse
import sys

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.enums import UserRole
from app.models.user import User


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed the first platform_admin user")
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--full-name", default="Platform Admin")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == args.email).first()
        if existing is not None:
            print(f"A user with email {args.email} already exists.", file=sys.stderr)
            sys.exit(1)

        admin = User(
            organization_id=None,
            email=args.email,
            hashed_password=hash_password(args.password),
            full_name=args.full_name,
            role=UserRole.platform_admin,
        )
        db.add(admin)
        db.commit()
        print(f"Created platform_admin user: {args.email}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
