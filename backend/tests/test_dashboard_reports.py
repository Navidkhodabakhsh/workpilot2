from tests.conftest import auth_headers


def _project_with_approved_worklog(client, admin_token, pm_token, emp_token, emp):
    project_id = client.post("/api/v1/projects", json={"name": "Dash"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    worklog_id = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 120, "progress_percent": 100, "log_date": "2026-07-14"},
        headers=auth_headers(emp_token),
    ).json()["id"]
    client.post(f"/api/v1/worklogs/{worklog_id}/approve", headers=auth_headers(pm_token))
    return project_id, task_id, worklog_id


def test_dashboard_summary_reflects_real_data(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    empty = client.get("/api/v1/dashboard/summary", headers=auth_headers(admin_token)).json()
    assert empty["project_count"] == 0

    _project_with_approved_worklog(client, admin_token, pm_token, emp_token, emp)

    summary = client.get("/api/v1/dashboard/summary", headers=auth_headers(admin_token)).json()
    assert summary["project_count"] == 1
    assert summary["task_count"] == 1
    assert summary["total_approved_hours"] == 2.0
    assert summary["team_hours"] == [{"user_id": emp["id"], "full_name": emp["full_name"], "approved_hours": 2.0}]


def test_dashboard_and_reports_are_isolated_per_organization(client, signup_org_admin, create_org_user):
    admin_a_token, _ = signup_org_admin("Org A")
    pm_token, _ = create_org_user(admin_a_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_a_token, "employee", "emp")
    _project_with_approved_worklog(client, admin_a_token, pm_token, emp_token, emp)

    admin_b_token, _ = signup_org_admin("Org B")
    summary_b = client.get("/api/v1/dashboard/summary", headers=auth_headers(admin_b_token)).json()
    assert summary_b["project_count"] == 0
    assert summary_b["total_approved_hours"] == 0.0

    report_b = client.get("/api/v1/reports/worklogs", headers=auth_headers(admin_b_token)).json()
    assert report_b["items"] == []


def test_report_filters(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    project_id, _, _ = _project_with_approved_worklog(client, admin_token, pm_token, emp_token, emp)

    resp = client.get("/api/v1/reports/worklogs", params={"project_id": project_id, "status": "approved"}, headers=auth_headers(admin_token))
    assert len(resp.json()["items"]) == 1

    resp = client.get("/api/v1/reports/worklogs", params={"project_id": project_id, "status": "rejected"}, headers=auth_headers(admin_token))
    assert len(resp.json()["items"]) == 0

    resp = client.get("/api/v1/reports/worklogs", params={"project_id": project_id, "date_from": "2026-07-15"}, headers=auth_headers(admin_token))
    assert len(resp.json()["items"]) == 0


def test_worklog_trend_buckets_approved_hours_by_period(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _project_with_approved_worklog(client, admin_token, pm_token, emp_token, emp)

    resp = client.get("/api/v1/reports/worklog-trend", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1
    assert items[0]["approved_hours"] == 2.0


def test_worklog_trend_is_isolated_per_organization(client, signup_org_admin):
    admin_b_token, _ = signup_org_admin("Org B Trend")
    resp = client.get("/api/v1/reports/worklog-trend", headers=auth_headers(admin_b_token))
    assert resp.status_code == 200
    assert resp.json()["items"] == []
