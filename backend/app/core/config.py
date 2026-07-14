from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "WorkPilot API"
    api_v1_prefix: str = "/api/v1"

    database_url: str = "postgresql+psycopg2://workpilot:workpilot@localhost:5432/workpilot"
    redis_url: str = "redis://localhost:6379/0"

    secret_key: str = "change-me-in-.env"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    cors_origins: list[str] = ["http://localhost:5173", "http://127.0.0.1:5173"]

    # Shared between the backend and worker containers via the same bind
    # mount (see docker-compose.yml) so the API can serve files the worker wrote.
    exports_dir: str = "exports"

    # False for local http development; set true via env var in production
    # (the browser silently drops Secure cookies over plain HTTP).
    cookie_secure: bool = False

    login_rate_limit_attempts: int = 5
    login_rate_limit_window_seconds: int = 300


settings = Settings()
