import random
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.rate_limit import check_and_increment
from app.core.security import hash_password, verify_password
from app.models.enums import OtpPurpose
from app.models.otp_code import OtpCode


def _generate_code() -> str:
    return f"{random.randint(0, 999999):06d}"


def request_otp(db: Session, phone_number: str, purpose: OtpPurpose) -> str | None:
    """Creates and stores a new OTP for this phone/purpose. Returns the raw
    code only when no real SMS provider is configured
    (settings.sms_provider_configured) so a caller can surface it for
    testing -- once a real provider is wired in, this should send the code
    instead and always return None. See docs/PROJECT_STATE.md for the
    current state of this limitation."""
    rate_key = f"otp_request:{purpose.value}:{phone_number}"
    if not check_and_increment(
        rate_key, settings.otp_request_rate_limit_attempts, settings.otp_request_rate_limit_window_seconds
    ):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many code requests. Please try again later.",
        )

    code = _generate_code()
    entry = OtpCode(
        phone_number=phone_number,
        code_hash=hash_password(code),
        purpose=purpose,
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=settings.otp_expire_minutes),
    )
    db.add(entry)
    db.commit()

    if settings.sms_provider_configured:
        # TODO: call the real SMS provider here once one is configured.
        return None
    return code


def verify_otp(db: Session, phone_number: str, code: str, purpose: OtpPurpose) -> bool:
    """Verifies (and consumes on success) the most recent unconsumed code
    for this phone/purpose. Returns False uniformly for a missing, expired,
    attempt-exhausted, or mismatched code -- callers should show one generic
    "invalid or expired code" error rather than distinguish these cases."""
    entry = (
        db.query(OtpCode)
        .filter(OtpCode.phone_number == phone_number, OtpCode.purpose == purpose, OtpCode.consumed_at.is_(None))
        .order_by(OtpCode.created_at.desc())
        .first()
    )
    if entry is None or entry.expires_at < datetime.now(timezone.utc):
        return False
    if entry.attempt_count >= settings.otp_verify_max_attempts:
        return False

    entry.attempt_count += 1
    if not verify_password(code, entry.code_hash):
        db.commit()
        return False

    entry.consumed_at = datetime.now(timezone.utc)
    db.commit()
    return True
