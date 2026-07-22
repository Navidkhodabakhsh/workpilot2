import httpx
import pytest

from app.core.config import settings
from app.services import otp as otp_service
from app.services import sms as sms_service


class _FakeResponse:
    def __init__(self, payload: dict, raise_error: Exception | None = None):
        self._payload = payload
        self._raise_error = raise_error

    def raise_for_status(self):
        if self._raise_error:
            raise self._raise_error

    def json(self):
        return self._payload


@pytest.fixture(autouse=True)
def _kavenegar_configured(monkeypatch):
    monkeypatch.setattr(settings, "kavenegar_api_key", "test-api-key")
    monkeypatch.setattr(settings, "kavenegar_otp_template", "verify")


def test_send_otp_sms_success_hits_the_verify_lookup_endpoint_with_the_right_params(monkeypatch):
    captured = {}

    def fake_get(url, params, timeout):
        captured["url"] = url
        captured["params"] = params
        return _FakeResponse({"return": {"status": 200, "message": "success"}, "entries": []})

    monkeypatch.setattr(sms_service.httpx, "get", fake_get)

    sms_service.send_otp_sms("09121234567", "123456")

    assert captured["url"] == "https://api.kavenegar.com/v1/test-api-key/verify/lookup.json"
    assert captured["params"] == {"receptor": "09121234567", "token": "123456", "template": "verify"}


def test_send_otp_sms_raises_on_kavenegar_level_error(monkeypatch):
    monkeypatch.setattr(
        sms_service.httpx,
        "get",
        lambda url, params, timeout: _FakeResponse({"return": {"status": 411, "message": "receptor invalid"}}),
    )

    with pytest.raises(Exception) as exc_info:
        sms_service.send_otp_sms("bad-number", "123456")
    assert getattr(exc_info.value, "status_code", None) == 502


def test_send_otp_sms_raises_on_transport_failure(monkeypatch):
    def fake_get(url, params, timeout):
        raise httpx.ConnectError("connection refused")

    monkeypatch.setattr(sms_service.httpx, "get", fake_get)

    with pytest.raises(Exception) as exc_info:
        sms_service.send_otp_sms("09121234567", "123456")
    assert getattr(exc_info.value, "status_code", None) == 502


def test_request_otp_sends_via_kavenegar_and_returns_no_code_when_configured(db_session, monkeypatch, unique_phone):
    from app.models.enums import OtpPurpose

    sent = {}
    monkeypatch.setattr(otp_service, "send_otp_sms", lambda phone, code: sent.update(phone=phone, code=code))

    phone = unique_phone()
    result = otp_service.request_otp(db_session, phone, OtpPurpose.login)

    assert result is None
    assert sent["phone"] == phone
    assert len(sent["code"]) == 6
