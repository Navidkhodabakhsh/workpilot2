from tests.conftest import auth_headers


def test_employee_project_member_only_sees_their_own_tasks_on_the_board(client, signup_org_admin, create_org_user):
    """Membership used to be enough to see every teammate's tasks on a
    project's board -- an employee should only ever see their own there,
    even though they're a full member of the project."""
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_a_token, emp_a = create_org_user(admin_token, "employee", "a")
    emp_b_token, emp_b = create_org_user(admin_token, "employee", "b")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    for uid in (emp_a["id"], emp_b["id"]):
        client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": uid}, headers=auth_headers(pm_token))

    task_a_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task A", "assignee_id": emp_a["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    task_b_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task B", "assignee_id": emp_b["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]

    # emp_a's board only shows their own task, not emp_b's.
    resp = client.get("/api/v1/tasks", params={"project_id": project_id}, headers=auth_headers(emp_a_token))
    assert resp.status_code == 200
    assert {t["title"] for t in resp.json()} == {"Task A"}

    # Direct fetch of a teammate's task is forbidden, not just hidden from the list.
    resp = client.get(f"/api/v1/tasks/{task_b_id}", headers=auth_headers(emp_a_token))
    assert resp.status_code == 403

    # ...but they can still fetch their own directly.
    resp = client.get(f"/api/v1/tasks/{task_a_id}", headers=auth_headers(emp_a_token))
    assert resp.status_code == 200

    # The project_manager and org_admin still see the whole board.
    resp = client.get("/api/v1/tasks", params={"project_id": project_id}, headers=auth_headers(pm_token))
    assert {t["title"] for t in resp.json()} == {"Task A", "Task B"}
    resp = client.get("/api/v1/tasks", params={"project_id": project_id}, headers=auth_headers(admin_token))
    assert {t["title"] for t in resp.json()} == {"Task A", "Task B"}
