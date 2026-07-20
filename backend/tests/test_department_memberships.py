from tests.conftest import auth_headers


def test_org_admin_can_set_multiple_department_memberships(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    dept_a = admin["department_id"]
    dept_b = client.post(
        "/api/v1/departments", json={"name": "منابع انسانی"}, headers=auth_headers(admin_token)
    ).json()["id"]

    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[
            {"department_id": dept_a, "role": "employee"},
            {"department_id": dept_b, "role": "project_manager"},
        ],
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 200, resp.text
    memberships = resp.json()["department_memberships"]
    assert len(memberships) == 2
    by_dept = {m["department_id"]: m["role"] for m in memberships}
    assert by_dept[dept_a] == "employee"
    assert by_dept[dept_b] == "project_manager"

    # /auth/me for that user reflects it too, not just the response of the PUT.
    me = client.get("/api/v1/auth/me", headers=auth_headers(emp_token))
    assert me.status_code == 200
    assert len(me.json()["department_memberships"]) == 2


def test_setting_memberships_replaces_the_previous_set(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    dept_a = admin["department_id"]
    dept_b = client.post(
        "/api/v1/departments", json={"name": "برنامه‌نویسی"}, headers=auth_headers(admin_token)
    ).json()["id"]
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[{"department_id": dept_a, "role": "employee"}],
        headers=auth_headers(admin_token),
    )
    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[{"department_id": dept_b, "role": "employee"}],
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 200
    memberships = resp.json()["department_memberships"]
    assert len(memberships) == 1
    assert memberships[0]["department_id"] == dept_b


def test_employee_cannot_set_department_memberships(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[{"department_id": admin["department_id"], "role": "employee"}],
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 403


def test_org_admin_role_rejected_in_department_membership(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[{"department_id": admin["department_id"], "role": "org_admin"}],
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 422


def test_department_from_another_org_is_rejected_in_membership(client, signup_org_admin, create_org_user):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, admin_b = signup_org_admin("Org B")
    emp_token, emp = create_org_user(admin_a_token, "employee", "emp")

    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[{"department_id": admin_b["department_id"], "role": "employee"}],
        headers=auth_headers(admin_a_token),
    )
    assert resp.status_code == 404


def test_duplicate_department_in_membership_list_is_rejected(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    emp_token, emp = create_org_user(admin_token, "employee", "emp")

    resp = client.put(
        f"/api/v1/users/{emp['id']}/departments",
        json=[
            {"department_id": admin["department_id"], "role": "employee"},
            {"department_id": admin["department_id"], "role": "project_manager"},
        ],
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 400
