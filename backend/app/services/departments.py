import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.department import Department
from app.models.enums import UserRole
from app.models.user import User
from app.schemas.department import DepartmentCreate


def create_department(db: Session, org_id: uuid.UUID, current_user: User, data: DepartmentCreate) -> Department:
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only an org_admin can create departments")

    department = Department(organization_id=org_id, name=data.name)
    db.add(department)
    db.commit()
    db.refresh(department)
    return department


def list_departments(db: Session, org_id: uuid.UUID) -> list[Department]:
    return db.query(Department).filter(Department.organization_id == org_id).order_by(Department.name).all()
