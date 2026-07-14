"""Minimal Redis-backed fixed-window rate limiter.

Used for login attempts, where the goal is just to slow down brute-force
guessing, not implement a general-purpose limiter -- a fixed window with
INCR+EXPIRE is sufficient and keeps this dependency-free beyond Redis
(already required for Celery).
"""

import redis

from app.core.config import settings

_redis_client = redis.Redis.from_url(settings.redis_url, decode_responses=True)


def check_and_increment(key: str, limit: int, window_seconds: int) -> bool:
    """Returns True if the call is allowed (and counts it), False if the
    limit for this window has already been reached."""
    current = _redis_client.incr(key)
    if current == 1:
        _redis_client.expire(key, window_seconds)
    return current <= limit


def reset(key: str) -> None:
    _redis_client.delete(key)
