import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import UserRole
from app.models.project import Project, ProjectMember
from app.models.user import User
from app.schemas.project import ProjectCreate, ProjectUpdate


class ProjectRepository(TenantScopedRepository[Project]):
    model = Project


def _is_member(db: Session, project_id: uuid.UUID, user_id: uuid.UUID) -> bool:
    return (
        db.query(ProjectMember)
        .filter(ProjectMember.project_id == project_id, ProjectMember.user_id == user_id)
        .first()
        is not None
    )


def assert_can_manage_project(db: Session, project: Project, current_user: User) -> None:
    """org_admin manages every project in the org; project_manager only the
    ones they belong to; employee can never manage (create/edit/delete)."""
    if current_user.role == UserRole.org_admin:
        return
    if current_user.role == UserRole.project_manager and _is_member(db, project.id, current_user.id):
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You cannot manage this project")


def assert_can_view_project(db: Session, project: Project, current_user: User) -> None:
    if current_user.role == UserRole.org_admin:
        return
    if _is_member(db, project.id, current_user.id):
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You are not a member of this project")


def create_project(db: Session, org_id: uuid.UUID, current_user: User, data: ProjectCreate) -> Project:
    if current_user.role not in (UserRole.org_admin, UserRole.project_manager):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only admins or project managers can create projects")

    repo = ProjectRepository(db, org_id)
    project = Project(
        name=data.name,
        description=data.description,
        start_date=data.start_date,
        end_date=data.end_date,
        created_by_id=current_user.id,
    )
    repo.add(project)

    # The creator is automatically a member so project_managers can always
    # manage/view what they just created.
    db.add(ProjectMember(project_id=project.id, user_id=current_user.id))
    db.commit()
    db.refresh(project)
    return project


def list_projects(db: Session, org_id: uuid.UUID, current_user: User) -> list[Project]:
    repo = ProjectRepository(db, org_id)
    if current_user.role == UserRole.org_admin:
        return repo.list(limit=500)

    member_project_ids = (
        db.query(ProjectMember.project_id).filter(ProjectMember.user_id == current_user.id).subquery()
    )
    return (
        db.query(Project)
        .filter(Project.organization_id == org_id, Project.id.in_(member_project_ids))
        .all()
    )


def get_project(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID) -> Project:
    repo = ProjectRepository(db, org_id)
    project = repo.get(project_id)
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    assert_can_view_project(db, project, current_user)
    return project


def update_project(
    db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID, data: ProjectUpdate
) -> Project:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)

    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(project, field, value)

    db.commit()
    db.refresh(project)
    return project


def add_member(
    db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID, member_user_id: uuid.UUID
) -> ProjectMember:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)

    target_user = db.get(User, member_user_id)
    if target_user is None or target_user.organization_id != org_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found in this organization")

    if _is_member(db, project_id, member_user_id):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User is already a project member")

    member = ProjectMember(project_id=project_id, user_id=member_user_id)
    db.add(member)
    db.commit()
    db.refresh(member)
    return member


def list_members(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID) -> list[ProjectMember]:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_view_project(db, project, current_user)
    return db.query(ProjectMember).filter(ProjectMember.project_id == project_id).all()


def remove_member(
    db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID, member_user_id: uuid.UUID
) -> None:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)

    member = (
        db.query(ProjectMember)
        .filter(ProjectMember.project_id == project_id, ProjectMember.user_id == member_user_id)
        .first()
    )
    if member is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Membership not found")

    db.delete(member)
    db.commit()
