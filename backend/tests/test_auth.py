from tests.conftest import PASSWORD, auth_headers


def test_signup_creates_org_admin(client, unique_phone):
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Acme",
            "department_name": "General",
            "full_name": "Admin User",
            "phone_number": unique_phone(),
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["role"] == "org_admin"
    assert body["organization_id"] is not None


def test_duplicate_signup_phone_is_conflict(client, unique_phone):
    phone = unique_phone()
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org1",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201
    resp2 = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org2",
            "department_name": "General",
            "full_name": "Admin B",
            "phone_number": phone,
            "password": PASSWORD,
        },
    )
    assert resp2.status_code == 409


def test_signup_without_department_name_creates_org_with_no_department(client, unique_phone):
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "No Department Org",
            "full_name": "Admin A",
            "phone_number": unique_phone(),
            "password": PASSWORD,
        },
    )
    assert resp.status_code == 201
    assert resp.json()["department_id"] is None


def test_wrong_password_is_unauthorized(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "password": PASSWORD,
        },
    )
    resp = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": "wrong"})
    assert resp.status_code == 401


def test_me_requires_a_token(client):
    resp = client.get("/api/v1/auth/me")
    assert resp.status_code == 401


def test_me_returns_current_user(client, signup_org_admin):
    token, _ = signup_org_admin()
    resp = client.get("/api/v1/auth/me", headers=auth_headers(token))
    assert resp.status_code == 200
    assert resp.json()["role"] == "org_admin"


def test_password_without_digit_is_rejected(client, unique_phone):
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": unique_phone(),
            "password": "alllowercase",
        },
    )
    assert resp.status_code == 422


def test_password_without_letter_is_rejected(client, unique_phone):
    resp = client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": unique_phone(),
            "password": "12345678",
        },
    )
    assert resp.status_code == 422


def test_refresh_flow_issues_a_new_access_token(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "password": PASSWORD,
        },
    )
    login_resp = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD})
    assert "refresh_token" in login_resp.cookies

    refresh_resp = client.post("/api/v1/auth/refresh")
    assert refresh_resp.status_code == 200
    new_token = refresh_resp.json()["access_token"]
    assert client.get("/api/v1/auth/me", headers=auth_headers(new_token)).status_code == 200


def test_refresh_without_a_cookie_is_unauthorized(client):
    resp = client.post("/api/v1/auth/refresh")
    assert resp.status_code == 401


def test_access_token_cannot_be_used_as_a_refresh_token(client, signup_org_admin):
    token, _ = signup_org_admin()
    client.cookies.set("refresh_token", token)
    resp = client.post("/api/v1/auth/refresh")
    assert resp.status_code == 401


def test_login_rate_limiting_blocks_after_five_attempts(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "password": PASSWORD,
        },
    )

    statuses = [
        client.post("/api/v1/auth/login", json={"phone_number": phone, "password": "WrongPassword123"}).status_code
        for _ in range(7)
    ]
    assert statuses[:5] == [401] * 5
    assert all(s == 429 for s in statuses[5:])

    # even the right password is blocked once the window is exceeded
    resp = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD})
    assert resp.status_code == 429


def test_login_with_unknown_phone_is_unauthorized(client):
    resp = client.post("/api/v1/auth/login", json={"phone_number": "09120000000", "password": "whatever123"})
    assert resp.status_code == 401


def test_create_additional_organization_for_existing_account(client, signup_org_admin):
    token, first_org = signup_org_admin("First Org")

    resp = client.post(
        "/api/v1/auth/organizations",
        json={"organization_name": "Second Org", "department_name": "General"},
        headers=auth_headers(token),
    )
    assert resp.status_code == 201
    second_user = resp.json()
    assert second_user["role"] == "org_admin"
    assert second_user["organization_id"] != first_org["organization_id"]

    orgs_resp = client.get("/api/v1/auth/organizations", headers=auth_headers(token))
    assert orgs_resp.status_code == 200
    org_ids = {o["organization_id"] for o in orgs_resp.json()}
    assert org_ids == {first_org["organization_id"], second_user["organization_id"]}


def test_switch_organization_reissues_token_for_that_org(client, signup_org_admin):
    token, first_org = signup_org_admin("First Org")
    second_user = client.post(
        "/api/v1/auth/organizations",
        json={"organization_name": "Second Org"},
        headers=auth_headers(token),
    ).json()

    switch_resp = client.post(
        "/api/v1/auth/switch-organization",
        json={"organization_id": second_user["organization_id"]},
        headers=auth_headers(token),
    )
    assert switch_resp.status_code == 200
    new_token = switch_resp.json()["access_token"]

    me = client.get("/api/v1/auth/me", headers=auth_headers(new_token)).json()
    assert me["organization_id"] == second_user["organization_id"]
    assert me["organization_id"] != first_org["organization_id"]


def test_same_phone_can_be_admin_of_one_org_and_employee_of_another(client, signup_org_admin, unique_phone, create_org_user):
    admin_token, admin_org = signup_org_admin("Org A")
    other_admin_token, other_org = signup_org_admin("Org B")

    employee_phone = unique_phone()
    add_resp = client.post(
        "/api/v1/users",
        json={"full_name": "Cross Org User", "phone_number": employee_phone, "role": "employee"},
        headers=auth_headers(other_admin_token),
    )
    assert add_resp.status_code == 201

    login_resp = client.post("/api/v1/auth/login", json={"phone_number": employee_phone, "password": PASSWORD})
    # This phone has no password of its own yet (invited by an admin without
    # one) -- so this specific assertion only checks the membership list,
    # not login; that's covered by the admin-set-password flow below.
    assert login_resp.status_code == 401

    set_password_resp = client.patch(
        f"/api/v1/users/{add_resp.json()['id']}",
        json={"password": PASSWORD},
        headers=auth_headers(other_admin_token),
    )
    assert set_password_resp.status_code == 200

    employee_token = client.post(
        "/api/v1/auth/login", json={"phone_number": employee_phone, "password": PASSWORD}
    ).json()["access_token"]
    orgs = client.get("/api/v1/auth/organizations", headers=auth_headers(employee_token)).json()
    assert {(o["organization_id"], o["role"]) for o in orgs} == {(other_org["organization_id"], "employee")}
    assert admin_org["organization_id"] != other_org["organization_id"]
