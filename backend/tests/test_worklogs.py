from tests.conftest import auth_headers


def _setup_task_for_employee(client, admin_token, pm_token, emp_token, emp):
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    return project_id, task_id


def test_only_assignee_can_log_work(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    other_token, _ = create_org_user(admin_token, "employee", "other")
    _, task_id = _setup_task_for_employee(client, admin_token, pm_token, emp_token, emp)

    resp = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "nope", "time_spent_minutes": 10, "progress_percent": 5, "log_date": "2026-07-14"},
        headers=auth_headers(other_token),
    )
    assert resp.status_code == 403

    # The task's creator (the manager who assigned it) is not the one doing
    # the work, so they may not log hours on it either -- only the assignee.
    resp = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "not mine to log", "time_spent_minutes": 10, "progress_percent": 5, "log_date": "2026-07-14"},
        headers=auth_headers(pm_token),
    )
    assert resp.status_code == 403

    resp = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "did it", "time_spent_minutes": 30, "progress_percent": 20, "log_date": "2026-07-14"},
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 201
    assert resp.json()["status"] == "submitted"


def test_approve_and_reject_flow(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, admin_token, pm_token, emp_token, emp)

    def log_work():
        return client.post(
            "/api/v1/worklogs",
            json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 30, "progress_percent": 20, "log_date": "2026-07-14"},
            headers=auth_headers(emp_token),
        ).json()["id"]

    # employee cannot review their own report
    wl1 = log_work()
    resp = client.post(f"/api/v1/worklogs/{wl1}/approve", headers=auth_headers(emp_token))
    assert resp.status_code == 403

    resp = client.post(f"/api/v1/worklogs/{wl1}/approve", headers=auth_headers(pm_token))
    assert resp.status_code == 200
    assert resp.json()["status"] == "approved"

    # can't re-review an already-reviewed log
    resp = client.post(f"/api/v1/worklogs/{wl1}/approve", headers=auth_headers(pm_token))
    assert resp.status_code == 400

    # reject requires a comment
    wl2 = log_work()
    resp = client.post(f"/api/v1/worklogs/{wl2}/reject", json={"review_comment": ""}, headers=auth_headers(pm_token))
    assert resp.status_code == 422

    resp = client.post(
        f"/api/v1/worklogs/{wl2}/reject", json={"review_comment": "needs more detail"}, headers=auth_headers(pm_token)
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "rejected"
    assert resp.json()["review_comment"] == "needs more detail"


def test_task_progress_only_moves_once_a_worklog_is_approved(client, signup_org_admin, create_org_user):
    """A project task's progress must not jump just because someone
    *submitted* a report claiming that much progress -- only an approved
    report should move it, and a rejected one must leave it untouched."""
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task_for_employee(client, admin_token, pm_token, emp_token, emp)

    def task_progress():
        return client.get(f"/api/v1/tasks/{task_id}", headers=auth_headers(pm_token)).json()["progress_percent"]

    assert task_progress() == 0

    wl1 = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 30, "progress_percent": 40, "log_date": "2026-07-14"},
        headers=auth_headers(emp_token),
    ).json()["id"]
    # Still just submitted -- progress must not have moved yet.
    assert task_progress() == 0

    client.post(f"/api/v1/worklogs/{wl1}/approve", headers=auth_headers(pm_token))
    assert task_progress() == 40

    wl2 = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "more work", "time_spent_minutes": 30, "progress_percent": 90, "log_date": "2026-07-15"},
        headers=auth_headers(emp_token),
    ).json()["id"]
    client.post(f"/api/v1/worklogs/{wl2}/reject", json={"review_comment": "not actually done"}, headers=auth_headers(pm_token))
    # Rejected -- the inflated 90% must never have applied.
    assert task_progress() == 40


def test_employee_cannot_list_worklogs_or_reports_for_a_project(client, signup_org_admin, create_org_user):
    """Regression guard: bulk worklog/report endpoints are manage-only, same
    as the approval queue they back -- a plain member must not be able to
    pull every member's raw entries by calling the endpoint directly."""
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    project_id, _ = _setup_task_for_employee(client, admin_token, pm_token, emp_token, emp)

    resp = client.get("/api/v1/worklogs", params={"project_id": project_id}, headers=auth_headers(emp_token))
    assert resp.status_code == 403

    resp = client.get("/api/v1/reports/worklogs", params={"project_id": project_id}, headers=auth_headers(emp_token))
    assert resp.status_code == 403

    # a manager can still reach both
    assert client.get("/api/v1/worklogs", params={"project_id": project_id}, headers=auth_headers(pm_token)).status_code == 200
    assert client.get("/api/v1/reports/worklogs", params={"project_id": project_id}, headers=auth_headers(pm_token)).status_code == 200
