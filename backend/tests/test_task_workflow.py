from tests.conftest import PASSWORD, auth_headers


def _setup_task_for_employee(client, pm_token, emp):
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    return project_id, task_id


def test_task_status_only_has_four_values(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]
    task = client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "Task"}, headers=auth_headers(admin_token)
    ).json()
    assert task["status"] == "todo"
    assert task["approval_status"] is None
    assert task["progress_percent"] == 0
    assert task["actual_hours"] == 0

    resp = client.patch(f"/api/v1/tasks/{task['id']}", json={"status": "in_review"}, headers=auth_headers(admin_token))
    assert resp.status_code == 422  # in_review no longer exists


def test_completing_a_task_sets_approval_pending_and_approve_reject_flow(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)

    resp = client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"}, headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert resp.json()["status"] == "completed"
    assert resp.json()["approval_status"] == "pending"

    # employee cannot approve their own task
    resp = client.post(f"/api/v1/tasks/{task_id}/approve", headers=auth_headers(emp_token))
    assert resp.status_code == 403

    resp = client.post(f"/api/v1/tasks/{task_id}/approve", headers=auth_headers(pm_token))
    assert resp.status_code == 200
    assert resp.json()["approval_status"] == "approved"

    # can't re-approve an already-decided task
    resp = client.post(f"/api/v1/tasks/{task_id}/approve", headers=auth_headers(pm_token))
    assert resp.status_code == 400


def test_reject_returns_task_to_in_progress(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)

    client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"}, headers=auth_headers(emp_token))
    resp = client.post(
        f"/api/v1/tasks/{task_id}/reject", json={"review_comment": "not done"}, headers=auth_headers(pm_token)
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "in_progress"
    assert resp.json()["approval_status"] == "rejected"


def test_personal_task_has_no_project_and_is_self_assigned(client, signup_org_admin):
    admin_token, admin = signup_org_admin()

    resp = client.post("/api/v1/tasks", json={"title": "Buy groceries"}, headers=auth_headers(admin_token))
    assert resp.status_code == 201
    body = resp.json()
    assert body["project_id"] is None
    assert body["assignee_id"] == admin["id"]


def test_personal_task_cannot_be_assigned_to_someone_else(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.post(
        "/api/v1/tasks", json={"title": "Nope", "assignee_id": emp["id"]}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 400


def test_personal_task_has_no_approval_workflow(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    task_id = client.post(
        "/api/v1/tasks", json={"title": "Personal"}, headers=auth_headers(admin_token)
    ).json()["id"]
    client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"}, headers=auth_headers(admin_token))

    resp = client.post(f"/api/v1/tasks/{task_id}/approve", headers=auth_headers(admin_token))
    assert resp.status_code == 400


def test_personal_tasks_filter(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": admin["id"]}, headers=auth_headers(pm_token))
    client.post("/api/v1/tasks", json={"project_id": project_id, "title": "Project task"}, headers=auth_headers(admin_token))
    client.post("/api/v1/tasks", json={"title": "My personal task"}, headers=auth_headers(admin_token))

    resp = client.get("/api/v1/tasks", params={"personal_only": "true"}, headers=auth_headers(admin_token))
    assert resp.status_code == 200
    titles = {t["title"] for t in resp.json()}
    assert titles == {"My personal task"}


def test_overdue_filter(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]
    client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Overdue", "deadline": "2020-01-01"},
        headers=auth_headers(admin_token),
    )
    client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Future", "deadline": "2099-01-01"},
        headers=auth_headers(admin_token),
    )

    resp = client.get("/api/v1/tasks", params={"overdue": "true"}, headers=auth_headers(admin_token))
    assert resp.status_code == 200
    titles = {t["title"] for t in resp.json()}
    assert titles == {"Overdue"}


def test_approval_status_filter(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)
    client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"}, headers=auth_headers(emp_token))

    resp = client.get("/api/v1/tasks", params={"approval_status": "pending"}, headers=auth_headers(pm_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1
    assert resp.json()[0]["id"] == task_id


def test_task_activity_log_records_lifecycle(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)

    client.patch(f"/api/v1/tasks/{task_id}", json={"status": "in_progress"}, headers=auth_headers(emp_token))
    client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"}, headers=auth_headers(emp_token))
    client.post(f"/api/v1/tasks/{task_id}/approve", headers=auth_headers(pm_token))
    client.post(
        f"/api/v1/tasks/{task_id}/comments", json={"body": "nice work"}, headers=auth_headers(pm_token)
    )

    resp = client.get(f"/api/v1/tasks/{task_id}/activity", headers=auth_headers(pm_token))
    assert resp.status_code == 200
    actions = [entry["action"] for entry in resp.json()]
    assert actions == ["task.create", "task.status_change", "task.status_change", "task.approve", "task.comment"]
    assert resp.json()[0]["actor_full_name"] == "Pm User"


def test_actual_hours_reflects_only_approved_worklogs(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)

    wl = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 90, "progress_percent": 50, "log_date": "2026-07-14"},
        headers=auth_headers(emp_token),
    ).json()

    resp = client.get(f"/api/v1/tasks/{task_id}", headers=auth_headers(pm_token))
    assert resp.json()["actual_hours"] == 0  # not approved yet

    client.post(f"/api/v1/worklogs/{wl['id']}/approve", headers=auth_headers(pm_token))

    resp = client.get(f"/api/v1/tasks/{task_id}", headers=auth_headers(pm_token))
    assert resp.json()["actual_hours"] == 1.5


def test_estimated_hours_and_progress_percent_roundtrip(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, pm_token, emp)

    resp = client.patch(
        f"/api/v1/tasks/{task_id}", json={"progress_percent": 40}, headers=auth_headers(emp_token)
    )
    assert resp.status_code == 200
    assert resp.json()["progress_percent"] == 40

    resp = client.patch(
        f"/api/v1/tasks/{task_id}", json={"estimated_hours": 12.5}, headers=auth_headers(pm_token)
    )
    assert resp.status_code == 200
    assert resp.json()["estimated_hours"] == 12.5
