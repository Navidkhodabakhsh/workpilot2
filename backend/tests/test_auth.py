from tests.conftest import PASSWORD, auth_headers


def test_signup_creates_org_admin(client, unique_email):
    email = unique_email("admin")
    resp = client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Acme", "full_name": "Admin User", "email": email, "password": PASSWORD},
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["role"] == "org_admin"
    assert body["organization_id"] is not None


def test_duplicate_signup_email_is_conflict(client, signup_org_admin, unique_email):
    email = unique_email("dupe")
    resp = client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org1", "full_name": "Admin A", "email": email, "password": PASSWORD},
    )
    assert resp.status_code == 201
    resp2 = client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org2", "full_name": "Admin B", "email": email, "password": PASSWORD},
    )
    assert resp2.status_code == 409


def test_wrong_password_is_unauthorized(client, unique_email):
    email = unique_email("wrongpass")
    client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org", "full_name": "Admin A", "email": email, "password": PASSWORD},
    )
    resp = client.post("/api/v1/auth/login", json={"identifier": email, "password": "wrong"})
    assert resp.status_code == 401


def test_me_requires_a_token(client):
    resp = client.get("/api/v1/auth/me")
    assert resp.status_code == 401


def test_me_returns_current_user(client, signup_org_admin):
    token, _ = signup_org_admin()
    resp = client.get("/api/v1/auth/me", headers=auth_headers(token))
    assert resp.status_code == 200
    assert resp.json()["role"] == "org_admin"


def test_password_without_digit_is_rejected(client, unique_email):
    resp = client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org", "full_name": "Admin A", "email": unique_email(), "password": "alllowercase"},
    )
    assert resp.status_code == 422


def test_password_without_letter_is_rejected(client, unique_email):
    resp = client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org", "full_name": "Admin A", "email": unique_email(), "password": "12345678"},
    )
    assert resp.status_code == 422


def test_refresh_flow_issues_a_new_access_token(client, unique_email):
    email = unique_email("refresh")
    client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org", "full_name": "Admin A", "email": email, "password": PASSWORD},
    )
    login_resp = client.post("/api/v1/auth/login", json={"identifier": email, "password": PASSWORD})
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


def test_login_rate_limiting_blocks_after_five_attempts(client, unique_email):
    email = unique_email("ratelimit")
    client.post(
        "/api/v1/auth/signup",
        json={"organization_name": "Org", "full_name": "Admin A", "email": email, "password": PASSWORD},
    )

    statuses = [
        client.post("/api/v1/auth/login", json={"identifier": email, "password": "WrongPassword123"}).status_code
        for _ in range(7)
    ]
    assert statuses[:5] == [401] * 5
    assert all(s == 429 for s in statuses[5:])

    # even the right password is blocked once the window is exceeded
    resp = client.post("/api/v1/auth/login", json={"identifier": email, "password": PASSWORD})
    assert resp.status_code == 429


def test_login_with_phone_number(client, unique_email):
    email = unique_email("phonelogin")
    phone = f"0912{abs(hash(email)) % 10_000_000:07d}"
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "full_name": "Admin A",
            "email": email,
            "phone_number": phone,
            "password": PASSWORD,
        },
    )
    resp = client.post("/api/v1/auth/login", json={"identifier": phone, "password": PASSWORD})
    assert resp.status_code == 200
    assert "access_token" in resp.json()


def test_login_with_unknown_phone_is_unauthorized(client):
    resp = client.post("/api/v1/auth/login", json={"identifier": "09120000000", "password": "whatever123"})
    assert resp.status_code == 401
