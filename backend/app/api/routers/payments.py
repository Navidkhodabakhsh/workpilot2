import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.payment import PaymentCreate, PaymentOut
from app.services import payments as payments_service

router = APIRouter(prefix="/projects/{project_id}/payments", tags=["payments"])


@router.post("", response_model=PaymentOut, status_code=201)
def create_payment(
    project_id: uuid.UUID,
    data: PaymentCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> PaymentOut:
    payment = payments_service.create_payment(db, org_id, current_user, project_id, data)
    return PaymentOut.model_validate(payment)


@router.get("", response_model=list[PaymentOut])
def list_payments(
    project_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[PaymentOut]:
    payments = payments_service.list_payments(db, org_id, current_user, project_id)
    return [PaymentOut.model_validate(p) for p in payments]


@router.delete("/{payment_id}", status_code=204)
def delete_payment(
    project_id: uuid.UUID,
    payment_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    payments_service.delete_payment(db, org_id, current_user, project_id, payment_id)
