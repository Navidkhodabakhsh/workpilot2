import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.project import ProjectCreate, ProjectMemberAdd, ProjectMemberOut, ProjectOut, ProjectUpdate
from app.services import projects as projects_service

router = APIRouter(prefix="/projects", tags=["projects"])


@router.post("", response_model=ProjectOut, status_code=201)
def create_project(
    data: ProjectCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ProjectOut:
    project = projects_service.create_project(db, org_id, current_user, data)
    return ProjectOut.model_validate(project)


@router.get("", response_model=list[ProjectOut])
def list_projects(
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[ProjectOut]:
    projects = projects_service.list_projects(db, org_id, current_user)
    return [ProjectOut.model_validate(p) for p in projects]


@router.get("/{project_id}", response_model=ProjectOut)
def get_project(
    project_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ProjectOut:
    project = projects_service.get_project(db, org_id, current_user, project_id)
    return ProjectOut.model_validate(project)


@router.patch("/{project_id}", response_model=ProjectOut)
def update_project(
    project_id: uuid.UUID,
    data: ProjectUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ProjectOut:
    project = projects_service.update_project(db, org_id, current_user, project_id, data)
    return ProjectOut.model_validate(project)


@router.get("/{project_id}/members", response_model=list[ProjectMemberOut])
def list_members(
    project_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[ProjectMemberOut]:
    members = projects_service.list_members(db, org_id, current_user, project_id)
    return [ProjectMemberOut.model_validate(m) for m in members]


@router.post("/{project_id}/members", response_model=ProjectMemberOut, status_code=201)
def add_member(
    project_id: uuid.UUID,
    data: ProjectMemberAdd,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> ProjectMemberOut:
    member = projects_service.add_member(db, org_id, current_user, project_id, data.user_id)
    return ProjectMemberOut.model_validate(member)


@router.delete("/{project_id}/members/{member_user_id}", status_code=204)
def remove_member(
    project_id: uuid.UUID,
    member_user_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    projects_service.remove_member(db, org_id, current_user, project_id, member_user_id)
