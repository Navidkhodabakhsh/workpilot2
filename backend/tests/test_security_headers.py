def test_baseline_security_headers_are_present(client):
    resp = client.get("/health")
    assert resp.headers["x-content-type-options"] == "nosniff"
    assert resp.headers["x-frame-options"] == "DENY"
    assert resp.headers["referrer-policy"] == "strict-origin-when-cross-origin"


def test_hsts_is_not_sent_over_plain_http(client):
    # The test client talks plain http, so Strict-Transport-Security --
    # which only makes sense once a client has already reached the app over
    # TLS -- must stay absent instead of incorrectly promising HTTPS.
    resp = client.get("/health")
    assert "strict-transport-security" not in resp.headers
