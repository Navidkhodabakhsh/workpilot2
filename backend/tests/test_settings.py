from tests.conftest import PASSWORD, auth_headers


def test_update_own_profile(client, signup_org_admin):
    token, _ = signup_org_admin()
    resp = client.patch("/api/v1/auth/me", json={"full_name": "New Name"}, headers=auth_headers(token))
    assert resp.status_code == 200
    assert resp.json()["full_name"] == "New Name"


def test_change_password_requires_correct_current_password(client, signup_org_admin):
    token, _ = signup_org_admin()
    resp = client.post(
        "/api/v1/auth/me/change-password",
        json={"current_password": "WrongPassword123", "new_password": "BrandNewPass123"},
        headers=auth_headers(token),
    )
    assert resp.status_code == 400


def test_change_password_succeeds_and_new_password_works(client, signup_org_admin):
    token, user = signup_org_admin()
    resp = client.post(
        "/api/v1/auth/me/change-password",
        json={"current_password": PASSWORD, "new_password": "BrandNewPass123"},
        headers=auth_headers(token),
    )
    assert resp.status_code == 200

    login_resp = client.post(
        "/api/v1/auth/login", json={"phone_number": user["phone_number"], "password": "BrandNewPass123"}
    )
    assert login_resp.status_code == 200


def test_org_admin_can_rename_organization(client, signup_org_admin):
    token, _ = signup_org_admin()
    resp = client.patch("/api/v1/organizations/me", json={"name": "Renamed Org"}, headers=auth_headers(token))
    assert resp.status_code == 200
    assert resp.json()["name"] == "Renamed Org"


def test_non_admin_cannot_rename_organization(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    resp = client.patch("/api/v1/organizations/me", json={"name": "Renamed Org"}, headers=auth_headers(emp_token))
    assert resp.status_code == 403
