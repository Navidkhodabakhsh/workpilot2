import re
import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password, verify_password
from app.models.department import Department
from app.models.enums import OtpPurpose, UserRole
from app.models.organization import Organization
from app.models.user import User
from app.schemas.auth import LoginRequest, SignupRequest
from app.services.audit import log_event
from app.services.otp import request_otp, verify_otp


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

    # Every organization must define at least one department at creation
    # time -- this is that department (purely a logical grouping, see
    # models/department.py).
    department = Department(organization_id=organization.id, name=data.department_name)
    db.add(department)
    db.flush()

    user = User(
        organization_id=organization.id,
        department_id=department.id,
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
    # hashed_password is None for an account invited by phone that hasn't
    # completed OTP verification yet -- treat that identically to a wrong
    # password rather than raising a different error (don't leak account state).
    if user is None or user.hashed_password is None or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    log_event(db, user.organization_id, user.id, "user.login", "user", str(user.id))
    db.commit()

    return user


def request_otp_for_phone(db: Session, phone_number: str, purpose: OtpPurpose) -> str | None:
    user = db.query(User).filter(User.phone_number == phone_number).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
    return request_otp(db, phone_number, purpose)


def otp_login(db: Session, phone_number: str, code: str, new_password: str | None) -> User:
    """Verifies a login-purpose OTP and returns the authenticated user. If
    the account has no password yet, new_password is required (the caller
    gets a 400 with a distinct detail so the frontend can prompt for one
    and resubmit); if the account already has a password, new_password is
    optional and, when given, replaces it -- OTP doubles as a recovery path
    for a returning user who forgot their password."""
    user = db.query(User).filter(User.phone_number == phone_number).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
    if not verify_otp(db, phone_number, code, OtpPurpose.login):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired code")

    if user.hashed_password is None and new_password is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="password_setup_required")
    if new_password is not None:
        user.hashed_password = hash_password(new_password)

    log_event(db, user.organization_id, user.id, "user.otp_login", "user", str(user.id))
    db.commit()
    db.refresh(user)
    return user


def otp_reset_password(db: Session, phone_number: str, code: str, new_password: str) -> User:
    user = db.query(User).filter(User.phone_number == phone_number).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
    if not verify_otp(db, phone_number, code, OtpPurpose.password_reset):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired code")

    user.hashed_password = hash_password(new_password)
    log_event(db, user.organization_id, user.id, "user.password_reset", "user", str(user.id))
    db.commit()
    db.refresh(user)
    return user


def issue_access_token(user: User) -> str:
    return create_access_token(user_id=user.id, organization_id=user.organization_id, role=user.role.value)
