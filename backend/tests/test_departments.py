from tests.conftest import PASSWORD, auth_headers, signup_otp_code


def test_signup_creates_the_named_department(client, unique_phone):
    phone = unique_phone()
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Dept Org",
            "department_name": "حسابداری",
            "full_name": "Admin",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201
    user = resp.json()
    assert user["department_id"] is not None

    login_resp = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD})
    token = login_resp.json()["access_token"]

    resp = client.get("/api/v1/departments", headers=auth_headers(token))
    assert resp.status_code == 200
    departments = resp.json()
    assert len(departments) == 1
    assert departments[0]["name"] == "حسابداری"
    assert departments[0]["id"] == user["department_id"]


def test_signup_without_department_name_creates_no_departments(client, unique_phone):
    phone = unique_phone()
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "No Dept Org",
            "full_name": "Admin",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201
    assert resp.json()["department_id"] is None

    token = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD}).json()["access_token"]
    resp = client.get("/api/v1/departments", headers=auth_headers(token))
    assert resp.status_code == 200
    assert resp.json() == []


def test_org_admin_can_add_a_second_department(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    resp = client.post("/api/v1/departments", json={"name": "برنامه‌نویسی"}, headers=auth_headers(admin_token))
    assert resp.status_code == 201

    resp = client.get("/api/v1/departments", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    names = {d["name"] for d in resp.json()}
    assert "برنامه‌نویسی" in names

    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    resp = client.post("/api/v1/departments", json={"name": "منابع انسانی"}, headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_departments_are_isolated_between_organizations(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")

    resp = client.get("/api/v1/departments", headers=auth_headers(admin_a_token))
    org_a_departments = {d["name"] for d in resp.json()}

    resp = client.get("/api/v1/departments", headers=auth_headers(admin_b_token))
    org_b_departments = {d["name"] for d in resp.json()}

    # both orgs use the same "General" department name from signup_org_admin,
    # but they must be entirely separate rows scoped to their own org
    assert len(org_a_departments) == 1
    assert len(org_b_departments) == 1


def test_assign_department_to_user_and_project(client, signup_org_admin, create_org_user):
    admin_token, admin = signup_org_admin()
    dept_id = client.post(
        "/api/v1/departments", json={"name": "منابع انسانی"}, headers=auth_headers(admin_token)
    ).json()["id"]

    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    resp = client.patch(
        f"/api/v1/users/{emp['id']}", json={"department_id": dept_id}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 200
    assert resp.json()["department_id"] == dept_id

    resp = client.post(
        "/api/v1/projects", json={"name": "Project", "department_id": dept_id}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 201
    assert resp.json()["department_id"] == dept_id


def test_department_from_another_org_is_rejected(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")

    other_org_dept_id = client.get("/api/v1/departments", headers=auth_headers(admin_b_token)).json()[0]["id"]

    resp = client.post(
        "/api/v1/projects",
        json={"name": "Project", "department_id": other_org_dept_id},
        headers=auth_headers(admin_a_token),
    )
    assert resp.status_code == 404
