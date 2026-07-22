import pytest

from app.core.config import Settings, docs_enabled_for_environment


def test_docs_are_reachable_under_the_default_development_settings(client):
    assert client.get("/docs").status_code == 200
    assert client.get("/openapi.json").status_code == 200


def test_docs_enabled_for_every_environment_except_production():
    assert docs_enabled_for_environment("production") is False
    assert docs_enabled_for_environment("development") is True
    assert docs_enabled_for_environment("staging") is True


def test_production_rejects_placeholder_secret_key():
    with pytest.raises(ValueError):
        Settings(environment="production", secret_key="change-me-in-.env")


def test_production_rejects_short_secret_key():
    with pytest.raises(ValueError):
        Settings(environment="production", secret_key="too-short")


def test_production_accepts_a_real_secret_key():
    settings = Settings(environment="production", secret_key="a" * 32)
    assert settings.environment == "production"


def test_development_allows_the_placeholder_secret_key():
    settings = Settings(environment="development", secret_key="change-me-in-.env")
    assert settings.secret_key == "change-me-in-.env"
