import uuid

from pydantic import BaseModel


class SearchProjectHit(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    name: str


class SearchTaskHit(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    title: str
    project_id: uuid.UUID


class SearchUserHit(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    full_name: str


class SearchResults(BaseModel):
    projects: list[SearchProjectHit]
    tasks: list[SearchTaskHit]
    users: list[SearchUserHit]
