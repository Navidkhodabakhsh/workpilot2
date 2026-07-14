"""Celery application entrypoint. Task modules are added in Phase F
(async Excel/PDF/CSV export jobs); this stub keeps the worker container
runnable from Phase A onward instead of crash-looping."""

from celery import Celery

from app.core.config import settings

celery_app = Celery("workpilot", broker=settings.redis_url, backend=settings.redis_url)
