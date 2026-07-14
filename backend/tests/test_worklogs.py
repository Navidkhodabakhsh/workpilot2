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
