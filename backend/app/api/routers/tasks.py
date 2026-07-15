import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_org_id, get_current_user
from app.db.session import get_db
from app.models.enums import ApprovalStatus, TaskStatus
from app.models.user import User
from app.schemas.task import (
    TaskActivityOut,
    TaskCreate,
    TaskDependencyCreate,
    TaskDependencyOut,
    TaskOut,
    TaskRejectRequest,
    TaskUpdate,
)
from app.services import task_activity as task_activity_service
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
    approval_status: ApprovalStatus | None = None,
    overdue: bool | None = None,
    personal_only: bool | None = None,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[TaskOut]:
    tasks = tasks_service.list_tasks(
        db, org_id, current_user, project_id, assignee_id, status_filter, approval_status, overdue, personal_only
    )
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


@router.post("/{task_id}/approve", response_model=TaskOut)
def approve_task(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskOut:
    task = tasks_service.approve_task(db, org_id, current_user, task_id)
    return TaskOut.model_validate(task)


@router.post("/{task_id}/reject", response_model=TaskOut)
def reject_task(
    task_id: uuid.UUID,
    data: TaskRejectRequest,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> TaskOut:
    task = tasks_service.reject_task(db, org_id, current_user, task_id, data.review_comment)
    return TaskOut.model_validate(task)


@router.get("/{task_id}/activity", response_model=list[TaskActivityOut])
def get_task_activity(
    task_id: uuid.UUID,
    db: Session = Depends(get_db),
    org_id: uuid.UUID = Depends(get_current_org_id),
    current_user: User = Depends(get_current_user),
) -> list[TaskActivityOut]:
    tasks_service.get_task(db, org_id, current_user, task_id)  # enforces view access
    rows = task_activity_service.list_task_activity(db, org_id, task_id)
    return [
        TaskActivityOut.model_validate(
            {
                "id": entry.id,
                "task_id": entry.task_id,
                "actor_user_id": entry.actor_user_id,
                "actor_full_name": actor_full_name,
                "action": entry.action,
                "extra_metadata": entry.extra_metadata,
                "created_at": entry.created_at,
            }
        )
        for entry, actor_full_name in rows
    ]


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
