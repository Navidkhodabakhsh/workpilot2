"""Celery application entrypoint."""

from celery import Celery

from app.core.config import settings

celery_app = Celery(
    "workpilot",
    broker=settings.redis_url,
    backend=settings.redis_url,
    include=["app.workers.tasks"],
)

celery_app.conf.beat_schedule = {
    "check-deadlines-daily": {
        "task": "check_deadlines",
        "schedule": 24 * 60 * 60,  # once a day; see docs/ARCHITECTURE.md for why a fixed interval is fine here
    }
}
