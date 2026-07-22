from datetime import datetime, timedelta, timezone

from app.models.enums import OtpPurpose
from app.models.otp_code import OtpCode
from app.services.otp import request_otp, verify_otp
from tests.conftest import PASSWORD, auth_headers, signup_otp_code


def _request_otp(client, phone_number: str, purpose: str = "login") -> str:
    resp = client.post("/api/v1/auth/otp/request", json={"phone_number": phone_number, "purpose": purpose})
    assert resp.status_code == 200, resp.text
    code = resp.json()["debug_code"]
    assert code is not None and len(code) == 6
    return code


def _invite_phone_only_user(client, admin_token, unique_phone, prefix: str = "invitee") -> str:
    phone = unique_phone()
    resp = client.post(
        "/api/v1/users",
        json={
            "full_name": f"{prefix.title()} User",
            "phone_number": phone,
        },
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 201, resp.text
    assert resp.json()["has_password"] is False
    return phone


def test_otp_request_for_unknown_phone_is_not_found(client):
    resp = client.post("/api/v1/auth/otp/request", json={"phone_number": "09120000001", "purpose": "login"})
    assert resp.status_code == 404


def test_first_login_with_no_password_requires_new_password(client, signup_org_admin, unique_phone):
    admin_token, _ = signup_org_admin()
    phone = _invite_phone_only_user(client, admin_token, unique_phone)

    code = _request_otp(client, phone)
    resp = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": code})
    assert resp.status_code == 400
    assert resp.json()["detail"] == "password_setup_required"


def test_first_login_with_new_password_sets_it_and_logs_in(client, signup_org_admin, unique_phone):
    admin_token, _ = signup_org_admin()
    phone = _invite_phone_only_user(client, admin_token, unique_phone)

    code = _request_otp(client, phone)
    resp = client.post(
        "/api/v1/auth/otp/login", json={"phone_number": phone, "code": code, "new_password": PASSWORD}
    )
    assert resp.status_code == 200, resp.text
    assert "access_token" in resp.json()

    # the password just set now works through the regular password login too
    login_resp = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD})
    assert login_resp.status_code == 200


def test_otp_login_without_new_password_works_when_password_already_set(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )

    code = _request_otp(client, phone)
    resp = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": code})
    assert resp.status_code == 200, resp.text
    assert "access_token" in resp.json()


def test_wrong_otp_code_is_unauthorized(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    _request_otp(client, phone)
    resp = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": "000000"})
    assert resp.status_code == 401


def test_otp_code_cannot_be_reused(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    code = _request_otp(client, phone)
    first = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": code})
    assert first.status_code == 200
    second = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": code})
    assert second.status_code == 401


def test_expired_otp_code_is_rejected(client, db_session, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    code = _request_otp(client, phone)

    entry = db_session.query(OtpCode).filter(OtpCode.phone_number == phone).order_by(OtpCode.created_at.desc()).first()
    entry.expires_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()

    resp = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": code})
    assert resp.status_code == 401


def test_otp_verify_locks_out_after_max_attempts(client, db_session, unique_phone):
    """Exercises services.otp.verify_otp directly: the router's own login
    rate limiter (also keyed at 5 attempts) would otherwise mask this
    OTP-specific attempt-count exhaustion if driven through the API."""
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    code = request_otp(db_session, phone, OtpPurpose.login)

    # 5 wrong attempts exhausts settings.otp_verify_max_attempts
    for _ in range(5):
        assert verify_otp(db_session, phone, "000000", OtpPurpose.login) is False

    # even the correct code is now rejected -- the code itself is spent
    assert verify_otp(db_session, phone, code, OtpPurpose.login) is False


def test_otp_request_rate_limiting_blocks_after_three_requests(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )

    statuses = [
        client.post("/api/v1/auth/otp/request", json={"phone_number": phone, "purpose": "login"}).status_code
        for _ in range(4)
    ]
    assert statuses[:3] == [200, 200, 200]
    assert statuses[3] == 429


def test_password_reset_flow_changes_password(client, unique_phone):
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )

    code = _request_otp(client, phone, purpose="password_reset")
    new_password = "BrandNewPass456"
    resp = client.post(
        "/api/v1/auth/otp/reset-password",
        json={"phone_number": phone, "code": code, "new_password": new_password},
    )
    assert resp.status_code == 200, resp.text
    assert "access_token" in resp.json()

    old_login = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": PASSWORD})
    assert old_login.status_code == 401

    new_login = client.post("/api/v1/auth/login", json={"phone_number": phone, "password": new_password})
    assert new_login.status_code == 200


def test_password_reset_code_cannot_be_used_for_login(client, unique_phone):
    """A password_reset-purpose code and a login-purpose code are tracked
    separately, so one can't be replayed against the other endpoint."""
    phone = unique_phone()
    client.post(
        "/api/v1/auth/signup",
        json={
            "organization_name": "Org",
            "department_name": "General",
            "full_name": "Admin A",
            "phone_number": phone,
            "code": signup_otp_code(client, phone),
            "password": PASSWORD,
        },
    )
    reset_code = _request_otp(client, phone, purpose="password_reset")
    resp = client.post("/api/v1/auth/otp/login", json={"phone_number": phone, "code": reset_code})
    assert resp.status_code == 401
