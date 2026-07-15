from tests.conftest import auth_headers


def _setup_task(client, admin_token, pm_token, emp_token, emp):
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    return project_id, task_id


def test_create_and_list_comments(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    resp = client.post(f"/api/v1/tasks/{task_id}/comments", json={"body": "Looks good"}, headers=auth_headers(pm_token))
    assert resp.status_code == 201
    assert resp.json()["body"] == "Looks good"
    assert resp.json()["author_full_name"]

    resp = client.get(f"/api/v1/tasks/{task_id}/comments", headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1


def test_comment_notifies_assignee_not_the_author(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    client.post(f"/api/v1/tasks/{task_id}/comments", json={"body": "Please check"}, headers=auth_headers(pm_token))

    assert client.get("/api/v1/notifications/unread-count", headers=auth_headers(emp_token)).json()["unread_count"] == 2
    # 2 = task_created (from setup) + comment_added
    notifs = client.get("/api/v1/notifications", headers=auth_headers(emp_token)).json()
    assert any(n["type"] == "comment_added" for n in notifs)


def test_non_member_cannot_comment(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    other_token, _ = create_org_user(admin_token, "employee", "other")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    resp = client.post(f"/api/v1/tasks/{task_id}/comments", json={"body": "hi"}, headers=auth_headers(other_token))
    assert resp.status_code == 403
