import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, require_role
from app.db.session import get_db
from app.models.enums import UserRole
from app.schemas.settings import OrganizationOut, OrganizationUpdate
from app.services import organizations as organizations_service

router = APIRouter(prefix="/organizations", tags=["organizations"])


@router.get("/me", response_model=OrganizationOut)
def get_my_organization(
    db: Session = Depends(get_db), org_id: uuid.UUID = Depends(get_current_org_id)
) -> OrganizationOut:
    org = organizations_service.get_organization(db, org_id)
    return OrganizationOut.model_validate(org)


@router.patch("/me", response_model=OrganizationOut)
def update_my_organization(
    data: OrganizationUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    _current_user=Depends(require_role(UserRole.org_admin)),
) -> OrganizationOut:
    org = organizations_service.update_organization(db, org_id, data.name)
    return OrganizationOut.model_validate(org)
