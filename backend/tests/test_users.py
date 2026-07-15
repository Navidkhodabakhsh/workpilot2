from tests.conftest import auth_headers


def test_org_admin_can_update_a_users_role(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, user = create_org_user(admin_token, "employee", "emp")

    resp = client.patch(
        f"/api/v1/users/{user['id']}", json={"role": "project_manager"}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 200
    assert resp.json()["role"] == "project_manager"


def test_org_admin_can_deactivate_another_user(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, user = create_org_user(admin_token, "employee", "emp")

    resp = client.patch(f"/api/v1/users/{user['id']}", json={"is_active": False}, headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert resp.json()["is_active"] is False


def test_org_admin_cannot_deactivate_self(client, signup_org_admin):
    admin_token, admin = signup_org_admin()

    resp = client.patch(
        f"/api/v1/users/{admin['id']}", json={"is_active": False}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 400


def test_employee_cannot_update_users(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, user = create_org_user(admin_token, "employee", "emp")

    resp = client.patch(f"/api/v1/users/{user['id']}", json={"role": "project_manager"}, headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_cross_org_user_update_returns_404(client, signup_org_admin, create_org_user):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")
    _, user_b = create_org_user(admin_b_token, "employee", "emp")

    resp = client.patch(
        f"/api/v1/users/{user_b['id']}", json={"role": "project_manager"}, headers=auth_headers(admin_a_token)
    )
    assert resp.status_code == 404


def test_cannot_assign_platform_admin_role(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, user = create_org_user(admin_token, "employee", "emp")

    resp = client.patch(
        f"/api/v1/users/{user['id']}", json={"role": "platform_admin"}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 422
