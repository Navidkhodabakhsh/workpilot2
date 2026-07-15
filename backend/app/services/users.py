import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models.enums import UserRole
from app.models.user import User
from app.schemas.user import OrgUserCreate, UserUpdate


def create_org_user(db: Session, org_id: uuid.UUID, current_user: User, data: OrgUserCreate) -> User:
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can add users")

    existing = db.query(User).filter(User.email == data.email).first()
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    if data.phone_number is not None:
        existing_phone = db.query(User).filter(User.phone_number == data.phone_number).first()
        if existing_phone is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Phone number already registered")

    user = User(
        organization_id=org_id,
        email=data.email,
        phone_number=data.phone_number,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=data.role,
    )
    db.add(user)
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

    if data.role is not None:
        target.role = data.role
    if data.is_active is not None:
        target.is_active = data.is_active

    db.commit()
    db.refresh(target)
    return target
