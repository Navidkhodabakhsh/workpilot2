import re
import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password, verify_password
from app.models.enums import UserRole
from app.models.organization import Organization
from app.models.user import User
from app.schemas.auth import LoginRequest, SignupRequest
from app.services.audit import log_event


def _slugify(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.strip().lower()).strip("-")
    return slug or uuid.uuid4().hex[:8]


def signup(db: Session, data: SignupRequest) -> User:
    """Creates a brand-new organization plus its first user, who becomes
    org_admin. This is the only path that creates an Organization outside of
    platform_admin tooling."""
    existing = db.query(User).filter(User.email == data.email).first()
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    if data.phone_number is not None:
        existing_phone = db.query(User).filter(User.phone_number == data.phone_number).first()
        if existing_phone is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")

    base_slug = _slugify(data.organization_name)
    slug = base_slug
    suffix = 1
    while db.query(Organization).filter(Organization.slug == slug).first() is not None:
        suffix += 1
        slug = f"{base_slug}-{suffix}"

    organization = Organization(name=data.organization_name, slug=slug)
    db.add(organization)
    db.flush()

    user = User(
        organization_id=organization.id,
        email=data.email,
        phone_number=data.phone_number,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=UserRole.org_admin,
    )
    db.add(user)
    db.flush()

    log_event(db, organization.id, user.id, "user.signup", "organization", str(organization.id))

    db.commit()
    db.refresh(user)
    return user


def authenticate(db: Session, data: LoginRequest) -> User:
    # Accept either an email or a phone number in the same field, user's choice.
    if "@" in data.identifier:
        user = db.query(User).filter(User.email == data.identifier).first()
    else:
        user = db.query(User).filter(User.phone_number == data.identifier).first()
    if user is None or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    log_event(db, user.organization_id, user.id, "user.login", "user", str(user.id))
    db.commit()

    return user


def issue_access_token(user: User) -> str:
    return create_access_token(user_id=user.id, organization_id=user.organization_id, role=user.role.value)
