import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import TaskStatus
from app.models.user import User
from app.schemas.task import (
    TaskCreate,
    TaskDependencyCreate,
    TaskDependencyOut,
    TaskOut,
    TaskUpdate,
)
from app.services import tasks as tasks_service

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.post("", response_model=TaskOut, status_code=201)
def create_task(
    data: TaskCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskOut:
    task = tasks_service.create_task(db, org_id, current_user, data)
    return TaskOut.model_validate(task)


@router.get("", response_model=list[TaskOut])
def list_tasks(
    project_id: uuid.UUID | None = None,
    assignee_id: uuid.UUID | None = None,
    status_filter: TaskStatus | None = Query(default=None, alias="status"),
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[TaskOut]:
    tasks = tasks_service.list_tasks(db, org_id, current_user, project_id, assignee_id, status_filter)
    return [TaskOut.model_validate(t) for t in tasks]


@router.get("/{task_id}", response_model=TaskOut)
def get_task(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskOut:
    task = tasks_service.get_task(db, org_id, current_user, task_id)
    return TaskOut.model_validate(task)


@router.patch("/{task_id}", response_model=TaskOut)
def update_task(
    task_id: uuid.UUID,
    data: TaskUpdate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskOut:
    task = tasks_service.update_task(db, org_id, current_user, task_id, data)
    return TaskOut.model_validate(task)


@router.delete("/{task_id}", status_code=204)
def delete_task(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> None:
    tasks_service.delete_task(db, org_id, current_user, task_id)


@router.post("/{task_id}/dependencies", response_model=TaskDependencyOut, status_code=201)
def add_dependency(
    task_id: uuid.UUID,
    data: TaskDependencyCreate,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskDependencyOut:
    dependency = tasks_service.add_dependency(db, org_id, current_user, task_id, data.depends_on_task_id)
    return TaskDependencyOut.model_validate(dependency)


@router.get("/{task_id}/dependencies", response_model=list[TaskDependencyOut])
def list_dependencies(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[TaskDependencyOut]:
    dependencies = tasks_service.list_dependencies(db, org_id, current_user, task_id)
    return [TaskDependencyOut.model_validate(d) for d in dependencies]
