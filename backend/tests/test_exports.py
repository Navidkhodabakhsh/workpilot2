import shutil

import pytest

from tests.conftest import auth_headers


@pytest.fixture(autouse=True)
def _isolated_exports_dir(tmp_path, monkeypatch):
    from app.core.config import settings

    monkeypatch.setattr(settings, "exports_dir", str(tmp_path))
    yield
    shutil.rmtree(tmp_path, ignore_errors=True)


def _project_with_approved_worklog(client, admin_token):
    project_id = client.post("/api/v1/projects", json={"name": "Export"}, headers=auth_headers(admin_token)).json()["id"]
    me = client.get("/api/v1/auth/me", headers=auth_headers(admin_token)).json()
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": me["id"]},
        headers=auth_headers(admin_token),
    ).json()["id"]
    worklog_id = client.post(
        "/api/v1/worklogs",
        json={"task_id": task_id, "activity_description": "work", "time_spent_minutes": 60, "progress_percent": 50, "log_date": "2026-07-14"},
        headers=auth_headers(admin_token),
    ).json()["id"]
    client.post(f"/api/v1/worklogs/{worklog_id}/approve", headers=auth_headers(admin_token))
    return project_id


@pytest.mark.parametrize(
    "export_type,magic_bytes",
    [("csv", b"\xef\xbb\xbf"), ("excel", b"PK"), ("pdf", b"%PDF")],
)
def test_export_job_generates_a_real_file(client, signup_org_admin, export_type, magic_bytes):
    admin_token, _ = signup_org_admin()
    project_id = _project_with_approved_worklog(client, admin_token)

    resp = client.post(
        "/api/v1/exports", json={"export_type": export_type, "project_id": project_id}, headers=auth_headers(admin_token)
    )
    assert resp.status_code == 201
    job_id = resp.json()["id"]

    # task_always_eager means the export already finished by the time .delay() returns
    status_resp = client.get(f"/api/v1/exports/{job_id}", headers=auth_headers(admin_token))
    assert status_resp.json()["status"] == "done"
    assert status_resp.json()["download_available"] is True

    download = client.get(f"/api/v1/exports/{job_id}/download", headers=auth_headers(admin_token))
    assert download.status_code == 200
    assert download.content.startswith(magic_bytes)
    assert b"WorkLogStatus" not in download.content  # enum repr bug regression check


def test_only_requester_or_org_admin_can_access_an_export_job(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    other_token, _ = create_org_user(admin_token, "employee", "other")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    job_id = client.post(
        "/api/v1/exports", json={"export_type": "csv", "project_id": project_id}, headers=auth_headers(pm_token)
    ).json()["id"]

    assert client.get(f"/api/v1/exports/{job_id}", headers=auth_headers(other_token)).status_code == 403
    assert client.get(f"/api/v1/exports/{job_id}", headers=auth_headers(admin_token)).status_code == 200


def test_export_job_cross_org_access_is_not_found(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_a_token)).json()["id"]
    job_id = client.post(
        "/api/v1/exports", json={"export_type": "csv", "project_id": project_id}, headers=auth_headers(admin_a_token)
    ).json()["id"]

    assert client.get(f"/api/v1/exports/{job_id}", headers=auth_headers(admin_b_token)).status_code == 404
