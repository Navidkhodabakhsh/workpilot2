from tests.conftest import auth_headers


def test_employee_can_create_project_task_for_self_log_time_and_manager_archives(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    employee_token, employee = create_org_user(admin_token, "employee", "employee")
    project_id = client.post(
        "/api/v1/projects", json={"name": "Workflow"}, headers=auth_headers(admin_token)
    ).json()["id"]
    client.post(
        f"/api/v1/projects/{project_id}/members",
        json={"user_id": employee["id"]},
        headers=auth_headers(admin_token),
    )

    task = client.post(
        "/api/v1/tasks",
        json={"project_id": project_id, "title": "Self opened", "value": "high"},
        headers=auth_headers(employee_token),
    )
    assert task.status_code == 201
    task_body = task.json()
    assert task_body["assignee_id"] == employee["id"]
    assert task_body["value"] == "high"

    worklog = client.post(
        "/api/v1/worklogs",
        json={
            "task_id": task_body["id"],
            "activity_description": "implementation",
            "time_spent_minutes": 75,
            "progress_percent": 70,
            "log_date": "2026-07-20",
        },
        headers=auth_headers(employee_token),
    )
    assert worklog.status_code == 201
    assert worklog.json()["status"] == "submitted"
    history = client.get(
        f"/api/v1/worklogs/task/{task_body['id']}", headers=auth_headers(employee_token)
    )
    assert history.status_code == 200
    assert history.json()[0]["time_spent_minutes"] == 75
    pending_task = client.get(
        f"/api/v1/tasks/{task_body['id']}", headers=auth_headers(employee_token)
    ).json()
    assert pending_task["pending_hours"] == 1.25
    assert pending_task["actual_hours"] == 0
    assert pending_task["total_logged_hours"] == 1.25

    client.post(
        f"/api/v1/worklogs/{worklog.json()['id']}/approve", headers=auth_headers(admin_token)
    )
    approved_task = client.get(
        f"/api/v1/tasks/{task_body['id']}", headers=auth_headers(employee_token)
    ).json()
    assert approved_task["actual_hours"] == 1.25
    assert approved_task["pending_hours"] == 0
    assert approved_task["total_logged_hours"] == 1.25

    client.patch(
        f"/api/v1/tasks/{task_body['id']}",
        json={"status": "completed"},
        headers=auth_headers(employee_token),
    )
    archived = client.post(
        f"/api/v1/tasks/{task_body['id']}/approve", headers=auth_headers(admin_token)
    )
    assert archived.status_code == 200
    assert archived.json()["status"] == "archived"
    assert archived.json()["approval_status"] == "approved"
    after_archive = client.post(
        "/api/v1/worklogs",
        json={
            "task_id": task_body["id"],
            "activity_description": "too late",
            "time_spent_minutes": 30,
            "progress_percent": 100,
            "log_date": "2026-07-20",
        },
        headers=auth_headers(employee_token),
    )
    assert after_archive.status_code == 400


def test_finance_ledger_groups_documents_and_is_manager_only(client, signup_org_admin, create_org_user):
    admin_token, _ = signup_org_admin()
    employee_token, _ = create_org_user(admin_token, "employee", "employee")
    manager_token, _ = create_org_user(admin_token, "project_manager", "manager")

    categories = client.get("/api/v1/finance/categories", headers=auth_headers(admin_token))
    assert categories.status_code == 200
    manager_categories = client.get("/api/v1/finance/categories", headers=auth_headers(manager_token))
    assert manager_categories.status_code == 200
    expense = next(item for item in categories.json() if item["name"] == "حقوق و دستمزد")

    document = client.post(
        "/api/v1/finance/entries",
        json={
            "entry_type": "expense",
            "category_id": expense["id"],
            "document_date": "2026-07-20",
            "amount": "2500000",
            "title": "حقوق تیر",
            "counterparty": "تیم عملیات",
            "document_number": "EXP-1001",
        },
        headers=auth_headers(admin_token),
    )
    assert document.status_code == 201
    assert document.json()["category_name"] == "حقوق و دستمزد"

    summary = client.get("/api/v1/finance/summary", headers=auth_headers(admin_token)).json()
    assert summary["total_expense"] == "2500000.00"
    assert summary["balance"] == "-2500000.00"
    assert summary["expense_breakdown"][0]["percent"] == 100.0

    forbidden = client.get("/api/v1/finance/entries", headers=auth_headers(employee_token))
    assert forbidden.status_code == 403


def test_finance_entries_can_be_sorted_by_amount_and_document_number(client, signup_org_admin):
    admin_token, _ = signup_org_admin()
    expense = next(
        item
        for item in client.get("/api/v1/finance/categories", headers=auth_headers(admin_token)).json()
        if item["entry_type"] == "expense"
    )

    def create(amount, document_number):
        return client.post(
            "/api/v1/finance/entries",
            json={
                "entry_type": "expense",
                "category_id": expense["id"],
                "document_date": "2026-07-20",
                "amount": amount,
                "title": f"Doc {document_number}",
                "document_number": document_number,
            },
            headers=auth_headers(admin_token),
        )

    create("500", "B-002")
    create("2500000", "A-001")
    create("100", "C-003")

    by_amount_asc = client.get(
        "/api/v1/finance/entries", params={"sort": "amount", "order": "asc"}, headers=auth_headers(admin_token)
    ).json()
    assert [row["amount"] for row in by_amount_asc] == ["100.00", "500.00", "2500000.00"]

    by_document_number_desc = client.get(
        "/api/v1/finance/entries", params={"sort": "document_number", "order": "desc"}, headers=auth_headers(admin_token)
    ).json()
    assert [row["document_number"] for row in by_document_number_desc] == ["C-003", "B-002", "A-001"]

    invalid_sort = client.get(
        "/api/v1/finance/entries", params={"sort": "not_a_real_column"}, headers=auth_headers(admin_token)
    )
    assert invalid_sort.status_code == 422
