import shutil

import pytest

from tests.conftest import auth_headers


@pytest.fixture(autouse=True)
def _isolated_attachments_dir(tmp_path, monkeypatch):
    from app.core.config import settings

    monkeypatch.setattr(settings, "attachments_dir", str(tmp_path))
    yield
    shutil.rmtree(tmp_path, ignore_errors=True)


def _setup_task(client, admin_token, pm_token, emp_token, emp):
    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(pm_token)).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": emp["id"]}, headers=auth_headers(pm_token))
    task_id = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Task", "assignee_id": emp["id"]},
        headers=auth_headers(pm_token),
    ).json()["id"]
    return project_id, task_id


def _create_finance_entry(client, token):
    categories = client.get("/api/v1/finance/categories", headers=auth_headers(token)).json()
    category = next(item for item in categories if item["entry_type"] == "expense")
    entry = client.post(
        "/api/v1/finance/entries",
        json={
            "entry_type": "expense",
            "category_id": category["id"],
            "document_date": "2026-07-20",
            "amount": "1000",
            "title": "Expense",
        },
        headers=auth_headers(token),
    ).json()
    return entry["id"]


def test_upload_list_download_and_delete_attachment(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    resp = client.post(
        f"/api/v1/tasks/{task_id}/attachments",
        files={"file": ("notes.txt", b"hello world", "text/plain")},
        headers=auth_headers(pm_token),
    )
    assert resp.status_code == 201
    attachment = resp.json()
    assert attachment["original_filename"] == "notes.txt"
    assert attachment["size_bytes"] == len(b"hello world")

    resp = client.get(f"/api/v1/tasks/{task_id}/attachments", headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1

    resp = client.get(f"/api/v1/attachments/{attachment['id']}/download", headers=auth_headers(emp_token))
    assert resp.status_code == 200
    assert resp.content == b"hello world"

    resp = client.get("/api/v1/attachments", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert resp.json()[0]["task_title"] == "Task"

    resp = client.delete(f"/api/v1/attachments/{attachment['id']}", headers=auth_headers(pm_token))
    assert resp.status_code == 204
    assert client.get(f"/api/v1/tasks/{task_id}/attachments", headers=auth_headers(emp_token)).json() == []


def test_non_uploader_non_manager_cannot_delete_attachment(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    attachment = client.post(
        f"/api/v1/tasks/{task_id}/attachments",
        files={"file": ("notes.txt", b"data", "text/plain")},
        headers=auth_headers(pm_token),
    ).json()

    resp = client.delete(f"/api/v1/attachments/{attachment['id']}", headers=auth_headers(emp_token))
    assert resp.status_code == 403


def test_non_member_cannot_upload_or_view_attachments(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, emp = create_org_user(admin_token, "employee", "emp")
    other_token, _ = create_org_user(admin_token, "employee", "other")
    _, task_id = _setup_task(client, admin_token, pm_token, emp_token, emp)

    resp = client.post(
        f"/api/v1/tasks/{task_id}/attachments",
        files={"file": ("notes.txt", b"data", "text/plain")},
        headers=auth_headers(other_token),
    )
    assert resp.status_code == 403


def test_attachments_are_scoped_to_organization(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")

    project_id = client.post("/api/v1/projects", json={"name": "Project"}, headers=auth_headers(admin_a_token)).json()["id"]
    task_id = client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "Task"}, headers=auth_headers(admin_a_token)
    ).json()["id"]
    attachment = client.post(
        f"/api/v1/tasks/{task_id}/attachments",
        files={"file": ("secret.txt", b"data", "text/plain")},
        headers=auth_headers(admin_a_token),
    ).json()

    resp = client.get(f"/api/v1/attachments/{attachment['id']}/download", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404

    resp = client.get("/api/v1/attachments", headers=auth_headers(admin_b_token))
    assert resp.json() == []


def test_finance_entry_attachment_upload_list_download_and_delete(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    emp_token, _ = create_org_user(admin_token, "employee", "emp")
    entry_id = _create_finance_entry(client, admin_token)

    resp = client.post(
        f"/api/v1/finance/entries/{entry_id}/attachments",
        files={"file": ("receipt.pdf", b"%PDF-1.4 fake", "application/pdf")},
        headers=auth_headers(pm_token),
    )
    assert resp.status_code == 201
    attachment = resp.json()
    assert attachment["finance_entry_id"] == entry_id
    assert attachment["task_id"] is None

    resp = client.get(f"/api/v1/finance/entries/{entry_id}/attachments", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert len(resp.json()) == 1

    resp = client.get(f"/api/v1/attachments/{attachment['id']}/download", headers=auth_headers(admin_token))
    assert resp.status_code == 200
    assert resp.content == b"%PDF-1.4 fake"

    # A plain employee has no finance access at all, so neither action is reachable.
    resp = client.post(
        f"/api/v1/finance/entries/{entry_id}/attachments",
        files={"file": ("x.txt", b"x", "text/plain")},
        headers=auth_headers(emp_token),
    )
    assert resp.status_code == 403
    resp = client.get(f"/api/v1/finance/entries/{entry_id}/attachments", headers=auth_headers(emp_token))
    assert resp.status_code == 403

    resp = client.delete(f"/api/v1/attachments/{attachment['id']}", headers=auth_headers(pm_token))
    assert resp.status_code == 204
    assert client.get(f"/api/v1/finance/entries/{entry_id}/attachments", headers=auth_headers(admin_token)).json() == []


def test_finance_entry_attachment_is_scoped_to_organization(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")
    entry_id = _create_finance_entry(client, admin_a_token)

    attachment = client.post(
        f"/api/v1/finance/entries/{entry_id}/attachments",
        files={"file": ("receipt.pdf", b"data", "application/pdf")},
        headers=auth_headers(admin_a_token),
    ).json()

    resp = client.get(f"/api/v1/attachments/{attachment['id']}/download", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404

    resp = client.get(f"/api/v1/finance/entries/{entry_id}/attachments", headers=auth_headers(admin_b_token))
    assert resp.status_code == 404
