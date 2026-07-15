from tests.conftest import auth_headers

RANGE = {"start": "2026-07-01T00:00:00Z", "end": "2026-08-01T00:00:00Z"}


def test_org_admin_can_create_a_meeting(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    resp = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Kickoff",
            "event_type": "meeting",
            "start_at": "2026-07-10T09:00:00Z",
            "end_at": "2026-07-10T10:00:00Z",
        },
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 201
    assert resp.json()["event_type"] == "meeting"


def test_employee_cannot_create_a_meeting(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    resp = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Nope",
            "event_type": "meeting",
            "start_at": "2026-07-10T09:00:00Z",
            "end_at": "2026-07-10T10:00:00Z",
        },
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 403


def test_employee_can_create_their_own_leave(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    resp = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Vacation",
            "event_type": "leave",
            "start_at": "2026-07-10T00:00:00Z",
            "end_at": "2026-07-12T00:00:00Z",
            "all_day": True,
        },
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 201
    assert resp.json()["user_id"] == emp["id"]


def test_employee_cannot_create_leave_for_someone_else(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    _, other = create_org_user(admin_token, "employee", "other")
    resp = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Vacation",
            "event_type": "leave",
            "start_at": "2026-07-10T00:00:00Z",
            "end_at": "2026-07-12T00:00:00Z",
            "user_id": other["id"],
        },
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 403


def test_end_before_start_is_rejected(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    resp = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Bad",
            "event_type": "meeting",
            "start_at": "2026-07-10T10:00:00Z",
            "end_at": "2026-07-10T09:00:00Z",
        },
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 422


def test_holiday_is_visible_to_everyone(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Public Holiday",
            "event_type": "holiday",
            "start_at": "2026-07-15T00:00:00Z",
            "end_at": "2026-07-15T23:59:59Z",
            "all_day": True,
        },
        headers=auth_headers(admin_token),
    )
    resp = client.get("/api/v1/calendar-events", params=RANGE, headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert any(e["title"] == "Public Holiday" for e in resp.json())


def test_leave_is_not_visible_to_unrelated_employee(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    other_token, _ = create_org_user(admin_token, "employee", "other")
    client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Private Leave",
            "event_type": "leave",
            "start_at": "2026-07-15T00:00:00Z",
            "end_at": "2026-07-15T23:59:59Z",
            "all_day": True,
        },
        headers=auth_headers(emp_token),
    )
    resp = client.get("/api/v1/calendar-events", params=RANGE, headers=auth_headers(other_token))
    assert resp.status_code == 200
    assert not any(e["title"] == "Private Leave" for e in resp.json())


def test_project_manager_sees_all_leave_events(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Employee Leave",
            "event_type": "leave",
            "start_at": "2026-07-15T00:00:00Z",
            "end_at": "2026-07-15T23:59:59Z",
            "all_day": True,
        },
        headers=auth_headers(emp_token),
    )
    resp = client.get("/api/v1/calendar-events", params=RANGE, headers=auth_headers(pm_token))
    assert resp.status_code == 200
    assert any(e["title"] == "Employee Leave" for e in resp.json())


def test_events_outside_range_are_excluded(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    client.post(
        "/api/v1/calendar-events",
        json={
            "title": "September Meeting",
            "event_type": "meeting",
            "start_at": "2026-09-10T09:00:00Z",
            "end_at": "2026-09-10T10:00:00Z",
        },
        headers=auth_headers(admin_token),
    )
    resp = client.get("/api/v1/calendar-events", params=RANGE, headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert not any(e["title"] == "September Meeting" for e in resp.json())


def test_update_and_delete_event(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    event_id = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Kickoff",
            "event_type": "meeting",
            "start_at": "2026-07-10T09:00:00Z",
            "end_at": "2026-07-10T10:00:00Z",
        },
        headers=auth_headers(admin_token),
    ).json()["id"]

    resp = client.patch(
        f"/api/v1/calendar-events/{event_id}",
        json={"start_at": "2026-07-10T11:00:00Z", "end_at": "2026-07-10T12:00:00Z"},
        headers=auth_headers(admin_token),
    )
    assert resp.status_code == 200
    assert resp.json()["start_at"].startswith("2026-07-10T11:00:00")

    resp = client.delete(f"/api/v1/calendar-events/{event_id}", headers=auth_headers(admin_token))
    assert resp.status_code == 204

    resp = client.get("/api/v1/calendar-events", params=RANGE, headers=auth_headers(admin_token))
    assert not any(e["id"] == event_id for e in resp.json())


def test_employee_cannot_update_someone_elses_event(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    event_id = client.post(
        "/api/v1/calendar-events",
        json={
            "title": "Kickoff",
            "event_type": "meeting",
            "start_at": "2026-07-10T09:00:00Z",
            "end_at": "2026-07-10T10:00:00Z",
        },
        headers=auth_headers(admin_token),
    ).json()["id"]

    resp = client.patch(
        f"/api/v1/calendar-events/{event_id}",
        json={"title": "Hijacked"},
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 403
