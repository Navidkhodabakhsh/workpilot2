import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.organization import Organization


def get_organization(db: Session, org_id: uuid.UUID) -> Organization:
    org = db.get(Organization, org_id)
    if org is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")
    return org


def update_organization(db: Session, org_id: uuid.UUID, name: str) -> Organization:
    org = get_organization(db, org_id)
    org.name = name
    db.commit()
    db.refresh(org)
    return org
