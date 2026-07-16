import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.enums import UserRole
from app.models.payment import Payment
from app.models.project import Project
from app.models.user import User
from app.schemas.payment import PaymentCreate


def _assert_owner(current_user: User) -> None:
    """Payments are intentionally restricted to the org owner only -- not
    even project_manager, unlike most other project-scoped operations."""
    if current_user.role != UserRole.org_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the organization owner can view payments")


def _get_project(db: Session, org_id: uuid.UUID, project_id: uuid.UUID) -> Project:
    project = db.query(Project).filter(Project.id == project_id, Project.organization_id == org_id).first()
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    return project


def create_payment(
    db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID, data: PaymentCreate
) -> Payment:
    _assert_owner(current_user)
    _get_project(db, org_id, project_id)

    payment = Payment(
        organization_id=org_id,
        project_id=project_id,
        recorded_by_id=current_user.id,
        payment_date=data.payment_date,
        description=data.description,
        amount=data.amount,
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment


def list_payments(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID) -> list[Payment]:
    _assert_owner(current_user)
    _get_project(db, org_id, project_id)

    return (
        db.query(Payment)
        .filter(Payment.organization_id == org_id, Payment.project_id == project_id)
        .order_by(Payment.payment_date.desc(), Payment.created_at.desc())
        .all()
    )


def delete_payment(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID, payment_id: uuid.UUID) -> None:
    _assert_owner(current_user)
    _get_project(db, org_id, project_id)

    payment = (
        db.query(Payment)
        .filter(Payment.id == payment_id, Payment.organization_id == org_id, Payment.project_id == project_id)
        .first()
    )
    if payment is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found")

    db.delete(payment)
    db.commit()
