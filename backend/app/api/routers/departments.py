import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.department import DepartmentCreate, DepartmentOut
from app.services import departments as departments_service

router = APIRouter(prefix="/departments", tags=["departments"])


@router.post("", response_model=DepartmentOut, status_code=201)
def create_department(
    data: DepartmentCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> DepartmentOut:
    department = departments_service.create_department(db, org_id, current_user, data)
    return DepartmentOut.model_validate(department)


@router.get("", response_model=list[DepartmentOut])
def list_departments(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[DepartmentOut]:
    departments = departments_service.list_departments(db, org_id)
    return [DepartmentOut.model_validate(d) for d in departments]
