import re
import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password, verify_password
from app.models.account import Account
from app.models.department import Department
from app.models.enums import OtpPurpose, UserRole
from app.models.organization import Organization
from app.models.user import User
from app.schemas.auth import CreateOrganizationRequest, LoginRequest, SignupRequest
from app.services.audit import log_event
from app.services.otp import request_otp, verify_otp


def _slugify(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.strip().lower()).strip("-")
    return slug or uuid.uuid4().hex[:8]


def _unique_slug(db: Session, name: str) -> str:
    base_slug = _slugify(name)
    slug = base_slug
    suffix = 1
    while db.query(Organization).filter(Organization.slug == slug).first() is not None:
        suffix += 1
        slug = f"{base_slug}-{suffix}"
    return slug


def _create_organization_with_department(
    db: Session, account_id: uuid.UUID, full_name: str, organization_name: str, department_name: str | None
) -> User:
    organization = Organization(name=organization_name, slug=_unique_slug(db, organization_name))
    db.add(organization)
    db.flush()

    department_id = None
    if department_name:
        department = Department(organization_id=organization.id, name=department_name)
        db.add(department)
        db.flush()
        department_id = department.id

    user = User(
        account_id=account_id,
        organization_id=organization.id,
        department_id=department_id,
        full_name=full_name,
        role=UserRole.org_admin,
    )
    db.add(user)
    db.flush()
    log_event(db, organization.id, user.id, "user.signup", "organization", str(organization.id))
    return user


def request_signup_otp(db: Session, phone_number: str) -> str | None:
    """Sends a signup-purpose code to a phone number that doesn't have an
    account yet -- the inverse precondition of request_otp_for_phone (used
    by login/password_reset), which requires the account to already exist."""
    existing = db.query(Account).filter(Account.phone_number == phone_number).first()
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")
    return request_otp(db, phone_number, OtpPurpose.signup)


def signup(db: Session, data: SignupRequest) -> User:
    """Creates a brand-new organization plus its first user, who becomes
    org_admin, under a brand-new Account. Requires a valid signup-purpose
    code (see request_signup_otp) proving ownership of the phone number.
    Rejects if the phone number already has an account -- an
    already-registered person who wants to found a *second* organization
    uses the authenticated create_additional_organization() below instead."""
    existing = db.query(Account).filter(Account.phone_number == data.phone_number).first()
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")
    if not verify_otp(db, data.phone_number, data.code, OtpPurpose.signup):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired code")

    account = Account(phone_number=data.phone_number, hashed_password=hash_password(data.password))
    db.add(account)
    db.flush()

    user = _create_organization_with_department(
        db, account.id, data.full_name, data.organization_name, data.department_name
    )

    db.commit()
    db.refresh(user)
    return user


def create_additional_organization(db: Session, current_user: User, data: CreateOrganizationRequest) -> User:
    """Lets an already-authenticated account found a second (or third, ...)
    organization, becoming its org_admin, while keeping every other
    membership untouched -- this is the mechanism for "one phone number is
    org_admin of one org and an employee of a different org"."""
    user = _create_organization_with_department(
        db, current_user.account_id, current_user.full_name, data.organization_name, data.department_name
    )

    db.commit()
    db.refresh(user)
    return user


def _pick_login_user(db: Session, account_id: uuid.UUID) -> User:
    """An Account can have several org memberships; login must resolve to
    exactly one for the initial JWT. Prefers an active membership (ordered
    by created_at, so the founding/oldest org wins ties) so a person
    disabled in one org can still get in via another; falls back to any
    membership so a fully-disabled account still surfaces the right error
    instead of a confusing 401. The org-switcher lets them change
    afterward."""
    memberships = db.query(User).filter(User.account_id == account_id).order_by(User.created_at).all()
    if not memberships:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    for membership in memberships:
        if membership.is_active:
            return membership
    return memberships[0]


def authenticate(db: Session, data: LoginRequest) -> User:
    account = db.query(Account).filter(Account.phone_number == data.phone_number).first()
    # hashed_password is None for an account invited by phone that hasn't
    # completed OTP verification yet -- treat that identically to a wrong
    # password rather than raising a different error (don't leak account state).
    if account is None or account.hashed_password is None or not verify_password(data.password, account.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    user = _pick_login_user(db, account.id)
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    log_event(db, user.organization_id, user.id, "user.login", "user", str(user.id))
    db.commit()

    return user


def request_otp_for_phone(db: Session, phone_number: str, purpose: OtpPurpose) -> str | None:
    account = db.query(Account).filter(Account.phone_number == phone_number).first()
    if account is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    user = _pick_login_user(db, account.id)
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
    account = db.query(Account).filter(Account.phone_number == phone_number).first()
    if account is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    user = _pick_login_user(db, account.id)
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
    if not verify_otp(db, phone_number, code, OtpPurpose.login):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired code")

    if account.hashed_password is None and new_password is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="password_setup_required")
    if new_password is not None:
        account.hashed_password = hash_password(new_password)

    log_event(db, user.organization_id, user.id, "user.otp_login", "user", str(user.id))
    db.commit()
    db.refresh(user)
    return user


def otp_reset_password(db: Session, phone_number: str, code: str, new_password: str) -> User:
    account = db.query(Account).filter(Account.phone_number == phone_number).first()
    if account is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No account is registered with this phone number")
    user = _pick_login_user(db, account.id)
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
    if not verify_otp(db, phone_number, code, OtpPurpose.password_reset):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired code")

    account.hashed_password = hash_password(new_password)
    log_event(db, user.organization_id, user.id, "user.password_reset", "user", str(user.id))
    db.commit()
    db.refresh(user)
    return user


def list_my_organizations(db: Session, current_user: User) -> list[User]:
    """Every membership (User row) for the caller's account, each carrying
    its own organization + role -- backs the organization switcher."""
    return (
        db.query(User)
        .filter(User.account_id == current_user.account_id, User.is_active.is_(True))
        .order_by(User.created_at)
        .all()
    )


def switch_organization(db: Session, current_user: User, organization_id: uuid.UUID) -> User:
    target = (
        db.query(User)
        .filter(User.account_id == current_user.account_id, User.organization_id == organization_id)
        .first()
    )
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="You are not a member of this organization")
    if not target.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled in this organization")
    return target


def issue_access_token(user: User) -> str:
    return create_access_token(user_id=user.id, organization_id=user.organization_id, role=user.role.value)
