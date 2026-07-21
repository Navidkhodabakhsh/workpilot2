from tests.conftest import PASSWORD, auth_headers


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


def test_org_admin_can_reset_password_and_phone_for_a_single_org_employee(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    _, user = create_org_user(admin_token, "employee", "emp")

    new_phone = "09355551234"
    resp = client.patch(
        f"/api/v1/users/{user['id']}",
        json={"password": "BrandNewPass123", "phone_number": new_phone},
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 200

    assert client.post(
        "/api/v1/auth/login", json={"phone_number": new_phone, "password": "BrandNewPass123"}
    ).status_code == 200


def test_org_admin_cannot_hijack_a_shared_multi_org_identitys_credentials(client, signup_org_admin, unique_phone):
    """Regression guard for a real cross-tenant privilege escalation: an
    org_admin must not be able to change the phone_number/password of a
    user whose Account is also a member of a different organization --
    those live on the shared Account, so changing them here would let this
    org's admin silently take over that person's login everywhere else,
    including in an organization they have no legitimate role in."""
    shared_phone = unique_phone()

    org_a_admin_token, _ = signup_org_admin("Org A")
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org B",
            "full_name": "Shared Identity",
            "phone_number": shared_phone,
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201, resp.text

    attach = client.post(
        "/api/v1/users",
        json={"full_name": "Shared Identity", "phone_number": shared_phone, "role": "employee"},
        headers=auth_headers(org_a_admin_token),
    )
    assert attach.status_code == 201, attach.text
    shared_user_in_org_a = attach.json()

    resp = client.patch(
        f"/api/v1/users/{shared_user_in_org_a['id']}",
        json={"password": "AttackerChosenPass1"},
        headers=auth_headers(org_a_admin_token),
    )
    assert resp.status_code == 409

    resp = client.patch(
        f"/api/v1/users/{shared_user_in_org_a['id']}",
        json={"phone_number": "09399998888"},
        headers=auth_headers(org_a_admin_token),
    )
    assert resp.status_code == 409

    # The original account's real password must still work -- confirms the
    # blocked request truly had no effect.
    assert client.post(
        "/api/v1/auth/login", json={"phone_number": shared_phone, "password": PASSWORD}
    ).status_code == 200

    # Non-identity fields (role, department, is_active) are unaffected by
    # this guard -- an org_admin can still fully manage the membership
    # itself, just not the shared login credentials behind it.
    resp = client.patch(
        f"/api/v1/users/{shared_user_in_org_a['id']}",
        json={"role": "project_manager"},
        headers=auth_headers(org_a_admin_token),
    )
    assert resp.status_code == 200
    assert resp.json()["role"] == "project_manager"
