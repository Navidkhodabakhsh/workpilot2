"""Base repository that enforces multi-tenant data isolation.

Every tenant-scoped model MUST have an `organization_id` column. Services should
query tenant data exclusively through a `TenantScopedRepository` subclass rather
than using `db.query(Model)` directly, so that forgetting to filter by
`organization_id` is not possible by construction. `platform_admin` operations
that need cross-tenant access should go through dedicated platform services,
not this repository.
"""

import uuid
from typing import Generic, TypeVar

from sqlalchemy.orm import Session

from app.db.base_class import Base

ModelType = TypeVar("ModelType", bound=Base)


class TenantScopedRepository(Generic[ModelType]):
    model: type[ModelType]

    def __init__(self, db: Session, organization_id: uuid.UUID):
        self.db = db
        self.organization_id = organization_id

    def _base_query(self):
        return self.db.query(self.model).filter(
            self.model.organization_id == self.organization_id
        )

    def get(self, id: uuid.UUID) -> ModelType | None:
        return self._base_query().filter(self.model.id == id).first()

    def list(self, *, limit: int = 50, offset: int = 0) -> list[ModelType]:
        return self._base_query().offset(offset).limit(limit).all()

    def add(self, obj: ModelType) -> ModelType:
        obj.organization_id = self.organization_id
        self.db.add(obj)
        self.db.flush()
        return obj

    def delete(self, obj: ModelType) -> None:
        self.db.delete(obj)
        self.db.flush()
