from tests.conftest import auth_headers


def test_employee_can_submit_a_leave_request(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    resp = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-03", "reason": "سفر خانوادگی"},
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 201, resp.text
    body = resp.json()
    assert body["status"] == "pending"
    assert body["reason"] == "سفر خانوادگی"
    assert body["user_full_name"] == "Emp User"


def test_end_date_before_start_date_is_rejected(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    resp = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-03", "end_date": "2026-08-01"},
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 422


def test_employee_only_sees_their_own_requests(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp1_token, _ = create_org_user(admin_token, "employee", "emp1")
    emp2_token, _ = create_org_user(admin_token, "employee", "emp2")

    client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp1_token),
    )
    client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-05", "end_date": "2026-08-06"},
        headers=auth_headers(emp2_token),
    )

    resp = client.get("/api/v1/leave-requests", headers=auth_headers(emp1_token))
    assert resp.status_code == 200
    items = resp.json()
    assert len(items) == 1
    assert items[0]["user_full_name"] == "Emp1 User"


def test_org_admin_sees_all_leave_requests_and_can_approve(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    leave_id = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp_token),
    ).json()["id"]

    resp = client.get("/api/v1/leave-requests", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1

    resp = client.post(f"/api/v1/leave-requests/{leave_id}/approve", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert resp.json()["status"] == "approved"

    resp = client.get("/api/v1/notifications", headers=auth_headers(emp_token))
    assert resp.status_code == 200
    types = [n["type"] for n in resp.json()]
    assert "leave_reviewed" in types


def test_project_manager_can_reject_with_comment(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    leave_id = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp_token),
    ).json()["id"]

    resp = client.post(
        f"/api/v1/leave-requests/{leave_id}/reject",
        json={"review_comment": "تداخل با تحویل پروژه"},
        headers=auth_headers(pm_token),
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "rejected"
    assert body["review_comment"] == "تداخل با تحویل پروژه"


def test_employee_cannot_approve_leave_requests(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    other_emp_token, _ = create_org_user(admin_token, "employee", "other")

    leave_id = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp_token),
    ).json()["id"]

    resp = client.post(f"/api/v1/leave-requests/{leave_id}/approve", headers=auth_headers(other_emp_token))
    assert resp.status_code == 403


def test_cannot_review_an_already_reviewed_request(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")

    leave_id = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp_token),
    ).json()["id"]

    client.post(f"/api/v1/leave-requests/{leave_id}/approve", headers=auth_headers(admin_token))
    resp = client.post(f"/api/v1/leave-requests/{leave_id}/approve", headers=auth_headers(admin_token))
    assert resp.status_code == 400


def test_leave_requests_are_isolated_between_organizations(client, signup_org_admin, create_org_user):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")
    emp_a_token, _ = create_org_user(admin_a_token, "employee", "empa")

    leave_id = client.post(
        "/api/v1/leave-requests",
        json={"start_date": "2026-08-01", "end_date": "2026-08-02"},
        headers=auth_headers(emp_a_token),
    ).json()["id"]

    resp = client.get(f"/api/v1/leave-requests/{leave_id}", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404

    resp = client.post(f"/api/v1/leave-requests/{leave_id}/approve", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404
