from datetime import date, timedelta

from tests.conftest import auth_headers


def test_task_assignment_notifies_the_assignee_not_the_creator(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))

    client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Notify Me", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    )

    assert client.get("/api/v1/notifications/unread-count", headers=auth_headers(emp_token)).json()["unread_count"] == 1
    assert client.get("/api/v1/notifications/unread-count", headers=auth_headers(pm_token)).json()["unread_count"] == 0

    notif = client.get("/api/v1/notifications", headers=auth_headers(emp_token)).json()[0]
    assert notif["type"] == "task_created"
    assert notif["payload"]["task_title"] == "Notify Me"


def test_mark_read_and_mark_all_read(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))

    for i in range(2):
        client.post(
            "/api/v1/tasks",
            json={"project_id": project_id, "title": f"Task {i}", "assignee_id": emp["id"]},
            headers=auth_headers(pm_token),
        )

    assert client.get("/api/v1/notifications/unread-count", headers=auth_headers(emp_token)).json()["unread_count"] == 2

    resp = client.post("/api/v1/notifications/read-all", headers=auth_headers(emp_token))
    assert resp.json()["updated"] == 2
    assert client.get("/api/v1/notifications/unread-count", headers=auth_headers(emp_token)).json()["unread_count"] == 0


def test_report_review_notifies_the_author_with_correct_status(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]}, headers=auth_headers(pm_token)
    ).json()["id"]
    worklog_id = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 10, "progress_percent": 10, "log_date": "2026-07-14"},
        headers=auth_headers(emp_token),
    ).json()["id"]

    client.post("/api/v1/notifications/read-all", headers=auth_headers(emp_token))
    client.post(f"/api/v1/worklogs/{worklog_id}/reject", json={"review_comment": "fix it"}, headers=auth_headers(pm_token))

    notifs = client.get("/api/v1/notifications", headers=auth_headers(emp_token)).json()
    reviewed = [n for n in notifs if n["type"] == "report_reviewed"]
    assert len(reviewed) == 1
    assert reviewed[0]["payload"]["status"] == "rejected"
    assert reviewed[0]["payload"]["review_comment"] == "fix it"


def test_deadline_reminder_is_sent_once_per_task(client, db_session, signup_org_admin, create_org_user):
    from app.services.notifications import check_deadlines_approaching

    admin_token, admin = signup_org_admin()
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(admin_token))

    near = (date.today() + timedelta(days=1)).isoformat()
    far = (date.today() + timedelta(days=10)).isoformat()
    client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Due soon", "assignee_id": emp["id"], "deadline": near},
        headers=auth_headers(admin_token),
    )
    client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Due later", "assignee_id": emp["id"], "deadline": far},
        headers=auth_headers(admin_token),
    )

    created_first = check_deadlines_approaching(db_session)
    assert created_first == 1

    created_second = check_deadlines_approaching(db_session)
    assert created_second == 0
