import os
import uuid

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

os.environ.setdefault("SECRET_KEY", "test-secret-key")

TEST_DATABASE_URL = os.environ.get(
    "TEST_DATABASE_URL", "postgresql+psycopg2://workpilot:workpilot@localhost:5432/workpilot_test"
)
# Must be set before app.db.session is imported anywhere (directly or
# transitively): its module-level `engine` is created from settings.database_url
# at import time. Without this, a Celery task's own SessionLocal() (used by
# app.workers.tasks, which cannot reuse the request-scoped test session) would
# silently write to the dev database instead of the test one -- the export
# job would look "stuck" forever because the task can't find the row.
os.environ["DATABASE_URL"] = TEST_DATABASE_URL

from app.db.base_class import Base  # noqa: E402
from app.db.session import get_db  # noqa: E402
from app.main import app  # noqa: E402
from app.models import *  # noqa: E402,F401,F403 -- registers every model on Base.metadata
from app.workers.celery_app import celery_app  # noqa: E402

# Run Celery tasks synchronously in-process instead of round-tripping
# through the Redis broker + a separate worker process, which the test
# suite shouldn't need to have running.
celery_app.conf.task_always_eager = True
celery_app.conf.task_eager_propagates = True


@pytest.fixture(scope="session")
def engine():
    # Connect to the default DB first to create the test DB if it doesn't exist.
    admin_url = TEST_DATABASE_URL.rsplit("/", 1)[0] + "/postgres"
    admin_engine = create_engine(admin_url, isolation_level="AUTOCOMMIT")
    db_name = TEST_DATABASE_URL.rsplit("/", 1)[1]
    with admin_engine.connect() as conn:
        exists = conn.execute(text("SELECT 1 FROM pg_database WHERE datname = :name"), {"name": db_name}).first()
        if not exists:
            conn.execute(text(f'CREATE DATABASE "{db_name}"'))
    admin_engine.dispose()

    test_engine = create_engine(TEST_DATABASE_URL)
    Base.metadata.create_all(test_engine)
    yield test_engine
    test_engine.dispose()


@pytest.fixture
def db_session(engine):
    """A real session that commits normally (our services call db.commit()
    themselves, same as in production). Isolation between tests is by
    truncating every table afterwards rather than a rollback-based
    savepoint trick, which is simpler to reason about and doesn't risk
    masking commit-related bugs in the code under test."""
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()

    yield session

    session.close()
    table_names = ", ".join(f'"{t.name}"' for t in reversed(Base.metadata.sorted_tables))
    with engine.begin() as conn:
        conn.execute(text(f"TRUNCATE TABLE {table_names} CASCADE"))


@pytest.fixture
def client(db_session):
    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def unique_email():
    def _make(prefix: str = "user") -> str:
        return f"{prefix}-{uuid.uuid4().hex[:10]}@example.com"

    return _make


@pytest.fixture
def unique_phone():
    def _make() -> str:
        return f"09{uuid.uuid4().int % 10**9:09d}"

    return _make


PASSWORD = "SuperSecret123"


@pytest.fixture
def signup_org_admin(client, unique_email, unique_phone):
    """Signs up a fresh organization and returns (access_token, user_dict)."""

    def _signup(org_name: str = "Test Org"):
        email = unique_email("admin")
        resp = client.post(
            "/api/v1/auth/signup",
            json={
                "organization_name": org_name,
                "department_name": "General",
                "full_name": "Admin User",
                "email": email,
                "phone_number": unique_phone(),
                "password": PASSWORD,
            },
        )
        assert resp.status_code == 201, resp.text
        login_resp = client.post("/api/v1/auth/login", json={"identifier": email, "password": PASSWORD})
        assert login_resp.status_code == 200, login_resp.text
        token = login_resp.json()["access_token"]
        return token, resp.json()

    return _signup


@pytest.fixture
def create_org_user(client, unique_email, unique_phone):
    """Creates a user with a given role inside an existing org (as its admin) and logs them in."""

    def _create(admin_token: str, role: str, prefix: str = "user"):
        email = unique_email(prefix)
        resp = client.post(
            "/api/v1/users",
            json={
                "full_name": f"{prefix.title()} User",
                "email": email,
                "phone_number": unique_phone(),
                "password": PASSWORD,
                "role": role,
            },
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 201, resp.text
        login_resp = client.post("/api/v1/auth/login", json={"identifier": email, "password": PASSWORD})
        token = login_resp.json()["access_token"]
        return token, resp.json()

    return _create


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}
