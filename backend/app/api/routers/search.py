import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.search import SearchResults
from app.services import search as search_service

router = APIRouter(prefix="/search", tags=["search"])


@router.get("", response_model=SearchResults)
def search(
    q: str = Query(min_length=2),
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> SearchResults:
    results = search_service.search(db, org_id, current_user, q)
    return SearchResults.model_validate(results)
