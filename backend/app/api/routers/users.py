import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import UserOut
from app.schemas.user import DepartmentMembershipIn, OrgUserCreate, UserUpdate
from app.services import users as users_service

router = APIRouter(prefix="/users", tags=["users"])


@router.post("", response_model=UserOut, status_code=201)
def create_user(
    data: OrgUserCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> UserOut:
    user = users_service.create_org_user(db, org_id, current_user, data)
    return UserOut.model_validate(user)


@router.get("", response_model=list[UserOut])
def list_users(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[UserOut]:
    users = users_service.list_org_users(db, org_id)
    return [UserOut.model_validate(u) for u in users]


@router.patch("/{user_id}", response_model=UserOut)
def update_user(
    user_id: uuid.UUID,
    data: UserUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> UserOut:
    user = users_service.update_org_user(db, org_id, current_user, user_id, data)
    return UserOut.model_validate(user)


@router.put("/{user_id}/departments", response_model=UserOut)
def set_user_departments(
    user_id: uuid.UUID,
    data: list[DepartmentMembershipIn],
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> UserOut:
    user = users_service.set_department_memberships(db, org_id, current_user, user_id, data)
    return UserOut.model_validate(user)
