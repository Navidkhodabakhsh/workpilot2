import uuid

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.db.tenant_repository import TenantScopedRepository
from app.models.enums import NotificationType, UserRole
from app.models.task import Task, TaskDependency
from app.models.user import User
from app.schemas.task import TaskCreate, TaskUpdate
from app.services.notifications import create_notification
from app.services.projects import assert_can_manage_project, assert_can_view_project, get_project


class TaskRepository(TenantScopedRepository[Task]):
    model = Task


def _can_manage_project_tasks(db: Session, org_id: uuid.UUID, current_user: User, project_id: uuid.UUID) -> None:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_manage_project(db, project, current_user)


def create_task(db: Session, org_id: uuid.UUID, current_user: User, data: TaskCreate) -> Task:
    _can_manage_project_tasks(db, org_id, current_user, data.project_id)

    if data.parent_task_id is not None:
        parent = TaskRepository(db, org_id).get(data.parent_task_id)
        if parent is None or parent.project_id != data.project_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="parent_task_id must reference a task in the same project",
            )

    task = Task(
        organization_id=org_id,
        project_id=data.project_id,
        parent_task_id=data.parent_task_id,
        assignee_id=data.assignee_id,
        created_by_id=current_user.id,
        title=data.title,
        description=data.description,
        priority=data.priority,
        deadline=data.deadline,
    )
    db.add(task)
    db.flush()

    if task.assignee_id is not None and task.assignee_id != current_user.id:
        create_notification(
            db,
            org_id,
            task.assignee_id,
            NotificationType.task_created,
            {"task_id": str(task.id), "task_title": task.title, "project_id": str(task.project_id)},
        )

    db.commit()
    db.refresh(task)
    return task


def list_tasks(
    db: Session,
    org_id: uuid.UUID,
    current_user: User,
    project_id: uuid.UUID,
    assignee_id: uuid.UUID | None = None,
    status_filter: str | None = None,
) -> list[Task]:
    project = get_project(db, org_id, current_user, project_id)
    assert_can_view_project(db, project, current_user)

    query = db.query(Task).filter(Task.organization_id == org_id, Task.project_id == project_id)
    if assignee_id is not None:
        query = query.filter(Task.assignee_id == assignee_id)
    if status_filter is not None:
        query = query.filter(Task.status == status_filter)
    return query.all()


def get_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> Task:
    task = TaskRepository(db, org_id).get(task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_view_project(db, project, current_user)
    return task


# Fields an `employee` is allowed to change on a task assigned to them.
_EMPLOYEE_ALLOWED_FIELDS = {"status"}


def update_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, data: TaskUpdate) -> Task:
    task = get_task(db, org_id, current_user, task_id)
    changes = data.model_dump(exclude_unset=True)

    if current_user.role == UserRole.employee:
        if task.assignee_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only update your own tasks")
        disallowed = set(changes) - _EMPLOYEE_ALLOWED_FIELDS
        if disallowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Employees may only update: {', '.join(sorted(_EMPLOYEE_ALLOWED_FIELDS))}",
            )
    else:
        project = get_project(db, org_id, current_user, task.project_id)
        assert_can_manage_project(db, project, current_user)

    for field, value in changes.items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)
    return task


def delete_task(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> None:
    task = get_task(db, org_id, current_user, task_id)
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)
    db.delete(task)
    db.commit()


def _depends_on_chain_reaches(db: Session, start_task_id: uuid.UUID, target_task_id: uuid.UUID) -> bool:
    """DFS over the depends_on graph starting at start_task_id: True if
    target_task_id is reachable, meaning adding (target -> start) would form a cycle."""
    seen: set[uuid.UUID] = set()
    stack = [start_task_id]
    while stack:
        current = stack.pop()
        if current == target_task_id:
            return True
        if current in seen:
            continue
        seen.add(current)
        deps = db.query(TaskDependency.depends_on_task_id).filter(TaskDependency.task_id == current).all()
        stack.extend(dep_id for (dep_id,) in deps)
    return False


def add_dependency(
    db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID, depends_on_task_id: uuid.UUID
) -> TaskDependency:
    task = get_task(db, org_id, current_user, task_id)
    project = get_project(db, org_id, current_user, task.project_id)
    assert_can_manage_project(db, project, current_user)

    if task_id == depends_on_task_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A task cannot depend on itself")

    depends_on_task = get_task(db, org_id, current_user, depends_on_task_id)
    if depends_on_task.project_id != task.project_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Dependencies must be within the same project"
        )

    # Would adding (task_id depends_on depends_on_task_id) create a cycle?
    # That happens iff task_id is already reachable by following
    # depends_on_task_id's own dependency chain.
    if _depends_on_chain_reaches(db, depends_on_task_id, task_id):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This dependency would create a cycle")

    existing = (
        db.query(TaskDependency)
        .filter(TaskDependency.task_id == task_id, TaskDependency.depends_on_task_id == depends_on_task_id)
        .first()
    )
    if existing is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Dependency already exists")

    dependency = TaskDependency(task_id=task_id, depends_on_task_id=depends_on_task_id)
    db.add(dependency)
    db.commit()
    db.refresh(dependency)
    return dependency


def list_dependencies(db: Session, org_id: uuid.UUID, current_user: User, task_id: uuid.UUID) -> list[TaskDependency]:
    get_task(db, org_id, current_user, task_id)  # enforces view access
    return db.query(TaskDependency).filter(TaskDependency.task_id == task_id).all()
