from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Anything the app has ever shipped as a placeholder default -- checked
# against secret_key below regardless of which one is currently in config.py
# or .env.example, so an old .env copied from an earlier version is still caught.
_INSECURE_SECRET_KEYS = {"change-me-in-.env", "change-me-generate-a-random-value", ""}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "WorkPilot API"
    api_v1_prefix: str = "/api/v1"

    # "development" (default) keeps /docs open and skips the secret-key
    # strength check below -- right for install.sh's self-hosted/LAN flow,
    # which documents the docs URL in its own printed output. Set to
    # "production" (see render.yaml) for a real internet-facing deployment.
    environment: str = "development"

    database_url: str = "postgresql+psycopg2://workpilot:workpilot@localhost:5432/workpilot"
    redis_url: str = "redis://localhost:6379/0"

    secret_key: str = "change-me-in-.env"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    cors_origins: list[str] = ["http://localhost:5173", "http://127.0.0.1:5173"]

    # Shared between the backend and worker containers via the same named
    # Docker volume (see docker-compose.yml) so the API can serve files the worker wrote.
    exports_dir: str = "exports"

    attachments_dir: str = "attachments"
    max_attachment_size_bytes: int = 10 * 1024 * 1024

    # False for local http development; set true via env var in production
    # (the browser silently drops Secure cookies over plain HTTP).
    cookie_secure: bool = False

    login_rate_limit_attempts: int = 5
    login_rate_limit_window_seconds: int = 300

    # Unset by default: otp endpoints return the generated code directly in
    # the API response instead of sending it anywhere, for local dev/testing
    # (see services/otp.py). Set KAVENEGAR_API_KEY to switch to actually
    # sending it via Kavenegar's Verify/Lookup API (https://kavenegar.com) --
    # once set, the response never contains the code.
    kavenegar_api_key: str | None = None
    # Must match a template already approved in the Kavenegar panel -- the
    # Verify/Lookup API sends that template with the code substituted in,
    # not free-form text (a carrier requirement for OTP-style messages).
    kavenegar_otp_template: str = "verify"
    otp_expire_minutes: int = 5
    otp_request_rate_limit_attempts: int = 3
    otp_request_rate_limit_window_seconds: int = 600
    otp_verify_max_attempts: int = 5

    # Unset by default -- error monitoring is opt-in. Set SENTRY_DSN to turn
    # it on; nothing about the app's behavior changes otherwise.
    sentry_dsn: str | None = None

    @model_validator(mode="after")
    def _guard_production_secret_key(self) -> "Settings":
        if self.environment == "production" and (
            self.secret_key in _INSECURE_SECRET_KEYS or len(self.secret_key) < 32
        ):
            raise ValueError(
                "SECRET_KEY is missing or too weak for ENVIRONMENT=production "
                "(need a real random value of at least 32 characters, e.g. `openssl rand -hex 32`)."
            )
        return self


settings = Settings()


def docs_enabled_for_environment(environment: str) -> bool:
    """Swagger UI/ReDoc/the raw schema are useful in development but are
    also a ready-made map of the API for anyone probing a real deployment."""
    return environment != "production"
