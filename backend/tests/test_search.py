from tests.conftest import auth_headers


def test_search_finds_projects_tasks_and_users(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, pm = create_org_user(admin_token, "project_manager", "pm")

    project_id = client.post(
        "/api/v1/projects", json={"name": "Marketing Website Revamp"}, headers=auth_headers(admin_token)
    ).json()["id"]
    client.post(f"/api/v1/projects/{project_id}/members", json={"user_id": pm["id"]}, headers=auth_headers(admin_token))
    client.post(
        "/api/v1/tasks", json={"project_id": project_id, "title": "Redesign marketing homepage"}, headers=auth_headers(admin_token)
    )

    resp = client.get("/api/v1/search", params={"q": "market"}, headers=auth_headers(admin_token))
    assert resp.status_code == 200
    body = resp.json()
    assert any("Marketing" in p["name"] for p in body["projects"])
    assert any("marketing" in t["title"].lower() for t in body["tasks"])

    resp = client.get("/api/v1/search", params={"q": "pm-"}, headers=auth_headers(admin_token))
    assert any(u["id"] == pm["id"] for u in resp.json()["users"])


def test_search_is_scoped_to_visible_projects(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    pm_token, _ = create_org_user(admin_token, "project_manager", "pm")
    other_pm_token, _ = create_org_user(admin_token, "project_manager", "other")

    client.post("/api/v1/projects", json={"name": "Only PM One Project"}, headers=auth_headers(pm_token))

    resp = client.get("/api/v1/search", params={"q": "Only"}, headers=auth_headers(other_pm_token))
    assert resp.status_code == 200
    assert resp.json()["projects"] == []


def test_search_is_scoped_to_organization(client, signup_org_admin):
    admin_a_token, _ = signup_org_admin("Org A")
    admin_b_token, _ = signup_org_admin("Org B")

    client.post("/api/v1/projects", json={"name": "Org A Secret Project"}, headers=auth_headers(admin_a_token))

    resp = client.get("/api/v1/search", params={"q": "Secret"}, headers=auth_headers(admin_b_token))
    assert resp.status_code == 200
    assert resp.json()["projects"] == []


def test_search_requires_at_least_two_characters(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    resp = client.get("/api/v1/search", params={"q": "a"}, headers=auth_headers(admin_token))
    assert resp.status_code == 422
