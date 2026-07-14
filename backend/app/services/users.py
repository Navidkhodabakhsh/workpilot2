import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models.enums import UserRole
from app.models.user import User
from app.schemas.user import OrgUserCreate


def create_org_user(db: Session, org_id: uuid.UUID, current_user: User, data: OrgUserCreate) -> User:
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can add users")

    existing = db.query(User).filter(User.email == data.email).first()
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    user = User(
        organization_id=org_id,
        email=data.email,
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
