"""Minimal Redis-backed fixed-window rate limiter.

Used for login attempts, where the goal is just to slow down brute-force
guessing, not implement a general-purpose limiter -- a fixed window with
INCR+EXPIRE is sufficient and keeps this dependency-free beyond Redis
(already required for Celery).
"""

import logging

import redis

from app.core.config import settings

logger = logging.getLogger(__name__)

_redis_client = redis.Redis.from_url(settings.redis_url, decode_responses=True)


def check_and_increment(key: str, limit: int, window_seconds: int) -> bool:
    """Returns True if the call is allowed (and counts it), False if the
    limit for this window has already been reached. Fails open (allows the
    call) if Redis itself is unreachable -- misconfigured/down infra
    shouldn't take down every login on top of losing the rate limit."""
    try:
        current = _redis_client.incr(key)
        if current == 1:
            _redis_client.expire(key, window_seconds)
        return current <= limit
    except redis.exceptions.RedisError:
        logger.warning("Rate limiter unavailable (Redis error) -- allowing request for key=%s", key)
        return True


def reset(key: str) -> None:
    try:
        _redis_client.delete(key)
    except redis.exceptions.RedisError:
        logger.warning("Rate limiter unavailable (Redis error) -- could not reset key=%s", key)
