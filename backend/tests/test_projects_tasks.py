from tests.conftest import auth_headers


def test_project_manager_can_create_and_manages_own_project(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")

    resp = client.post("/api/v1/projects", json={"name": "Website"}, headers=auth_headers(pm_token))
    assert resp.status_code == 201
    project_id = resp.json()["id"]

    # creator is auto-added as a member, so they can manage it
    resp = client.patch(f"/api/v1/projects/{project_id}", json={"status": "completed"}, headers=auth_headers(pm_token))
    assert resp.status_code == 200
    assert resp.json()["status"] == "completed"


def test_employee_cannot_create_a_project(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    resp = client.post("/api/v1/projects", json={"name": "Nope"}, headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_non_member_cannot_view_a_project(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    project_id = client.post("/api/v1/projects", json={"name": "Private"}, headers=auth_headers(pm_token)).json()["id"]

    resp = client.get(f"/api/v1/projects/{project_id}", headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_cross_org_project_access_returns_404_not_403(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")

    project_id = client.post("/api/v1/projects", json={"name": "Org A Project"}, headers=auth_headers(admin_a_token)).json()["id"]

    resp = client.get(f"/api/v1/projects/{project_id}", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404  # not 403 -- org B shouldn't even learn the project exists


def test_employee_can_update_working_details_of_their_own_task(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))

    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]

    resp = client.patch(f"/api/v1/tasks/{task_id}", json={"status": "in_progress"}, headers=auth_headers(emp_token))
    assert resp.status_code == 200

    resp = client.patch(f"/api/v1/tasks/{task_id}", json={"priority": "high"}, headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert resp.json()["priority"] == "high"


def test_list_tasks_without_project_id_returns_all_visible_tasks(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    other_pm_token, _ = create_org_user(admin_token, "project_manager", "other")

    p1 = client.post("/api/v1/projects", json={"name": "P1"}, headers=auth_headers(pm_token)).json()["id"]
    p2 = client.post("/api/v1/projects", json={"name": "P2"}, headers=auth_headers(other_pm_token)).json()["id"]
    client.post("/api/v1/tasks", json={"project_id": p1, "title": "Task in P1"}, headers=auth_headers(pm_token))
    client.post("/api/v1/tasks", json={"project_id": p2, "title": "Task in P2"}, headers=auth_headers(other_pm_token))

    resp = client.get("/api/v1/tasks", headers=auth_headers(pm_token))
    assert resp.status_code == 200
    titles = {t["title"] for t in resp.json()}
    assert titles == {"Task in P1"}  # pm is only a member of P1, not P2

    resp = client.get("/api/v1/tasks", headers=auth_headers(admin_token))
    assert {t["title"] for t in resp.json()} == {"Task in P1", "Task in P2"}  # org_admin sees the whole org


def test_assignee_sees_task_even_without_project_membership(client, signup_org_admin, create_org_user):
    """A manager assigning a task to someone shouldn't be blocked on also
    remembering to add them as a formal project member -- being the
    assignee is itself enough to view (and find in "my tasks") the task."""
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    # Deliberately NOT adding emp as a project member here.
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]

    resp = client.get(f"/api/v1/tasks/{task_id}", headers=auth_headers(emp_token))
    assert resp.status_code == 200

    resp = client.get("/api/v1/tasks", params={"assignee_id": emp["id"]}, headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert {t["title"] for t in resp.json()} == {"Task"}

    # but the employee still can't see the *whole* project (Kanban board),
    # since that requires actual membership, not just being assigned one task
    resp = client.get(f"/api/v1/projects/{project_id}", headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_create_project_with_manager_and_members(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, pm = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.post(
        "/api/v1/projects",
        json={"name": "Staffed Project", "manager_id": pm["id"], "member_ids": [emp["id"]]},
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 201
    project = resp.json()
    assert project["manager_id"] == pm["id"]

    # both the designated manager and the listed member were auto-added,
    # so they can each interact with the project without a separate step
    resp = client.get(f"/api/v1/projects/{project['id']}", headers=auth_headers(pm_token))
    assert resp.status_code == 200
    resp = client.get(f"/api/v1/projects/{project['id']}", headers=auth_headers(emp_token))
    assert resp.status_code == 200


def test_create_project_rejects_employee_as_manager(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.post(
        "/api/v1/projects", json={"name": "Project", "manager_id": emp["id"]}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 400


def test_task_dependency_cycle_is_rejected(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    t1 = client.post("/api/v1/tasks", json={"project_id": project_id, "title": "T1"}, headers=auth_headers(pm_token)).json()["id"]
    t2 = client.post("/api/v1/tasks", json={"project_id": project_id, "title": "T2"}, headers=auth_headers(pm_token)).json()["id"]

    resp = client.post(f"/api/v1/tasks/{t2}/dependencies", json={"depends_on_task_id": t1}, headers=auth_headers(pm_token))
    assert resp.status_code == 201

    resp = client.post(f"/api/v1/tasks/{t1}/dependencies", json={"depends_on_task_id": t2}, headers=auth_headers(pm_token))
    assert resp.status_code == 400

    resp = client.post(f"/api/v1/tasks/{t1}/dependencies", json={"depends_on_task_id": t1}, headers=auth_headers(pm_token))
    assert resp.status_code == 400


def test_newly_created_task_appears_first_in_the_list(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Ordering Project"}, headers=auth_headers(admin_token)).json()["id"]

    first_id = client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "First task"}, headers=auth_headers(admin_token)
    ).json()["id"]
    second_id = client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "Second task"}, headers=auth_headers(admin_token)
    ).json()["id"]

    ids_in_order = [t["id"] for t in client.get("/api/v1/tasks", headers=auth_headers(admin_token)).json()]
    assert ids_in_order.index(second_id) < ids_in_order.index(first_id)


def test_newly_created_project_appears_first_in_the_list(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    first_id = client.post("/api/v1/projects", json={"name": "First project"}, headers=auth_headers(admin_token)).json()["id"]
    second_id = client.post("/api/v1/projects", json={"name": "Second project"}, headers=auth_headers(admin_token)).json()["id"]

    ids_in_order = [p["id"] for p in client.get("/api/v1/projects", headers=auth_headers(admin_token)).json()]
    assert ids_in_order.index(second_id) < ids_in_order.index(first_id)
