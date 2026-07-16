from tests.conftest import auth_headers


def test_org_admin_can_create_and_list_payments(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]

    resp = client.post(
        f"/api/v1/projects/{project_id}/payments",
        json={"payment_date": "2026-07-01", "description": "پیش‌پرداخت اولیه", "amount": "1500000.00"},
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 201, resp.text
    payment = resp.json()
    assert payment["project_id"] == project_id
    assert payment["description"] == "پیش‌پرداخت اولیه"

    resp = client.get(f"/api/v1/projects/{project_id}/payments", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1


def test_project_manager_cannot_access_payments(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]

    resp = client.post(
        f"/api/v1/projects/{project_id}/payments",
        json={"payment_date": "2026-07-01", "description": "x", "amount": "100"},
        headers=auth_headers(pm_token),
    )
    assert resp.status_code == 403

    resp = client.get(f"/api/v1/projects/{project_id}/payments", headers=auth_headers(pm_token))
    assert resp.status_code == 403


def test_employee_cannot_access_payments(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]

    resp = client.get(f"/api/v1/projects/{project_id}/payments", headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_cross_org_project_payments_is_not_found(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")
    project_id = client.post("/api/v1/projects", json={"name": "Org A Project"}, headers=auth_headers(admin_a_token)).json()["id"]

    resp = client.get(f"/api/v1/projects/{project_id}/payments", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404


def test_org_admin_can_delete_a_payment(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]
    payment_id = client.post(
        f"/api/v1/projects/{project_id}/payments",
        json={"payment_date": "2026-07-01", "description": "x", "amount": "500"},
        headers=auth_headers(admin_token),
    ).json()["id"]

    resp = client.delete(f"/api/v1/projects/{project_id}/payments/{payment_id}", headers=auth_headers(admin_token))
    assert resp.status_code == 204

    resp = client.get(f"/api/v1/projects/{project_id}/payments", headers=auth_headers(admin_token))
    assert resp.json() == []


def test_payment_amount_must_be_positive(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_token)).json()["id"]

    resp = client.post(
        f"/api/v1/projects/{project_id}/payments",
        json={"payment_date": "2026-07-01", "description": "x", "amount": "0"},
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 422
