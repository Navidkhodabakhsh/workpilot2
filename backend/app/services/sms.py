import logging

import httpx
from fastapi import HTTPException, status

from app.core.config import settings

logger = logging.getLogger(__name__)

KAVENEGAR_BASE_URL = "https://api.kavenegar.com/v1"


def send_otp_sms(phone_number: str, code: str) -> None:
    """Sends `code` to `phone_number` through Kavenegar's Verify/Lookup API
    -- the endpoint meant for OTP-style messages, which sends a
    pre-approved template (registered in the Kavenegar panel) instead of
    free-form text. Raises HTTPException on any failure so the caller
    surfaces "delivery failed" instead of telling the user a code was
    sent when it wasn't."""
    url = f"{KAVENEGAR_BASE_URL}/{settings.kavenegar_api_key}/verify/lookup.json"
    params = {"receptor": phone_number, "token": code, "template": settings.kavenegar_otp_template}

    try:
        response = httpx.get(url, params=params, timeout=10.0)
        response.raise_for_status()
    except httpx.HTTPError as exc:
        logger.error("Kavenegar request failed for %s: %s", phone_number, exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to send verification code"
        ) from exc

    body = response.json()
    return_status = body.get("return", {}).get("status")
    if return_status != 200:
        message = body.get("return", {}).get("message", "unknown error")
        logger.error("Kavenegar rejected OTP send for %s: status=%s message=%s", phone_number, return_status, message)
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to send verification code")
