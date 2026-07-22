import sentry_sdk
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routers import (
    attachments,
    audit,
    auth,
    calendar_events,
    comments,
    dashboard,
    departments,
    exports,
    finance,
    health,
    leave_requests,
    notifications,
    organizations,
    payments,
    projects,
    reports,
    search,
    tasks,
    users,
    worklogs,
)
from app.core.config import docs_enabled_for_environment, settings
from app.core.logging_config import configure_logging
from app.core.security_headers import SecurityHeadersMiddleware

configure_logging()

# Opt-in: only reports errors if SENTRY_DSN is actually set (see
# Settings.sentry_dsn); the app behaves identically without it.
if settings.sentry_dsn:
    sentry_sdk.init(dsn=settings.sentry_dsn, environment=settings.environment, send_default_pii=False)

# See docs_enabled_for_environment's docstring -- closed in production
# (backend/.env.example / render.yaml).
_docs_enabled = docs_enabled_for_environment(settings.environment)
app = FastAPI(
    title=settings.app_name,
    docs_url="/docs" if _docs_enabled else None,
    redoc_url="/redoc" if _docs_enabled else None,
    openapi_url="/openapi.json" if _docs_enabled else None,
)

app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router, prefix=settings.api_v1_prefix)
app.include_router(users.router, prefix=settings.api_v1_prefix)
app.include_router(projects.router, prefix=settings.api_v1_prefix)
app.include_router(tasks.router, prefix=settings.api_v1_prefix)
app.include_router(worklogs.router, prefix=settings.api_v1_prefix)
app.include_router(dashboard.router, prefix=settings.api_v1_prefix)
app.include_router(reports.router, prefix=settings.api_v1_prefix)
app.include_router(exports.router, prefix=settings.api_v1_prefix)
app.include_router(finance.router, prefix=settings.api_v1_prefix)
app.include_router(notifications.router, prefix=settings.api_v1_prefix)
app.include_router(audit.router, prefix=settings.api_v1_prefix)
app.include_router(search.router, prefix=settings.api_v1_prefix)
app.include_router(organizations.router, prefix=settings.api_v1_prefix)
app.include_router(comments.router, prefix=settings.api_v1_prefix)
app.include_router(attachments.task_attachments_router, prefix=settings.api_v1_prefix)
app.include_router(attachments.finance_attachments_router, prefix=settings.api_v1_prefix)
app.include_router(attachments.attachments_router, prefix=settings.api_v1_prefix)
app.include_router(calendar_events.router, prefix=settings.api_v1_prefix)
app.include_router(calendar_events.categories_router, prefix=settings.api_v1_prefix)
app.include_router(payments.router, prefix=settings.api_v1_prefix)
app.include_router(departments.router, prefix=settings.api_v1_prefix)
app.include_router(leave_requests.router, prefix=settings.api_v1_prefix)
