import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models.account import Account
from app.models.department import Department
from app.models.department_membership import DepartmentMembership
from app.models.enums import UserRole
from app.models.user import User
from app.schemas.user import DepartmentMembershipIn, OrgUserCreate, UserUpdate


def _validate_department(db: Session, org_id: uuid.UUID, department_id: uuid.UUID) -> None:
    department = db.query(Department).filter(Department.id == department_id, Department.organization_id == org_id).first()
    if department is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Department not found in this organization")


def _sync_primary_membership(db: Session, org_id: uuid.UUID, user: User) -> None:
    """Keeps a DepartmentMembership row in sync with User.department_id/.role
    so `department_memberships` (the thing the frontend actually reads for
    "which departments is this person in") always includes the primary
    department too, not just extras added via set_department_memberships --
    called after create/update touches either field. No-op for org_admin
    (department-scoped roles don't apply) or when no department is set."""
    if user.department_id is None or user.role not in (UserRole.project_manager, UserRole.employee):
        return
    existing = (
        db.query(DepartmentMembership)
        .filter(DepartmentMembership.user_id == user.id, DepartmentMembership.department_id == user.department_id)
        .first()
    )
    if existing is not None:
        existing.role = user.role
    else:
        db.add(
            DepartmentMembership(
                organization_id=org_id, user_id=user.id, department_id=user.department_id, role=user.role
            )
        )


def create_org_user(db: Session, org_id: uuid.UUID, current_user: User, data: OrgUserCreate) -> User:
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can add users")

    account = db.query(Account).filter(Account.phone_number == data.phone_number).first()
    if account is not None:
        already_member = (
            db.query(User).filter(User.account_id == account.id, User.organization_id == org_id).first()
        )
        if already_member is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")
        # This phone number already has an identity elsewhere (e.g. it's a
        # member of a different organization) -- attach this membership to
        # that existing account instead of creating a second one. Any
        # `password` submitted here is ignored: the identity's password is
        # already set, and only that account holder should be able to
        # change it (via their own login).
    else:
        account = Account(phone_number=data.phone_number, hashed_password=hash_password(data.password) if data.password else None)
        db.add(account)
        db.flush()

    if data.department_id is not None:
        _validate_department(db, org_id, data.department_id)

    user = User(
        account_id=account.id,
        organization_id=org_id,
        department_id=data.department_id,
        full_name=data.full_name,
        role=data.role,
    )
    db.add(user)
    db.flush()
    _sync_primary_membership(db, org_id, user)
    db.commit()
    db.refresh(user)
    return user


def list_org_users(db: Session, org_id: uuid.UUID) -> list[User]:
    return db.query(User).filter(User.organization_id == org_id).all()


def update_org_user(
    db: Session, org_id: uuid.UUID, current_user: User, target_user_id: uuid.UUID, data: UserUpdate
) -> User:
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can edit users")

    target = db.query(User).filter(User.id == target_user_id, User.organization_id == org_id).first()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if target.id == current_user.id and data.is_active is False:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You cannot deactivate your own account")

    if data.phone_number is not None or data.password is not None:
        # phone_number/password live on the shared Account, not this
        # org-scoped User row -- changing them here would change the login
        # credentials for every organization this account belongs to. If
        # it's shared with another org, an admin of *this* org must not be
        # able to reach into that: it would let any org_admin silently
        # hijack a shared identity's access to a completely unrelated
        # organization. Only allow it when this org is the account's only
        # membership.
        other_org_membership = (
            db.query(User)
            .filter(User.account_id == target.account_id, User.organization_id != org_id)
            .first()
        )
        if other_org_membership is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This identity belongs to more than one organization; its phone number and password can only be changed by the account holder themselves",
            )

    if data.phone_number is not None:
        existing_phone = (
            db.query(Account).filter(Account.phone_number == data.phone_number, Account.id != target.account_id).first()
        )
        if existing_phone is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")
        target.account.phone_number = data.phone_number

    if data.password is not None:
        target.account.hashed_password = hash_password(data.password)

    if data.department_id is not None:
        _validate_department(db, org_id, data.department_id)
        target.department_id = data.department_id
    if data.role is not None:
        target.role = data.role
    if data.is_active is not None:
        target.is_active = data.is_active

    if data.department_id is not None or data.role is not None:
        db.flush()
        _sync_primary_membership(db, org_id, target)

    db.commit()
    db.refresh(target)
    return target


def set_department_memberships(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    target_user_id: uuid.UUID,
    memberships: list[DepartmentMembershipIn],
) -> User:
    """Replaces the target user's full set of department memberships with
    the given list (empty list clears them all) -- simpler for a UI that
    edits the whole set at once than exposing separate add/remove endpoints."""
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can edit users")

    target = db.query(User).filter(User.id == target_user_id, User.organization_id == org_id).first()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if target.role not in (UserRole.project_manager, UserRole.employee):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Department memberships only apply to project_manager/employee users",
        )

    department_ids = [m.department_id for m in memberships]
    if len(set(department_ids)) != len(department_ids):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Duplicate department in membership list")
    for department_id in department_ids:
        _validate_department(db, org_id, department_id)

    db.query(DepartmentMembership).filter(DepartmentMembership.user_id == target.id).delete()
    for membership in memberships:
        db.add(
            DepartmentMembership(
                organization_id=org_id,
                user_id=target.id,
                department_id=membership.department_id,
                role=membership.role,
            )
        )

    db.commit()
    db.refresh(target)
    return target
