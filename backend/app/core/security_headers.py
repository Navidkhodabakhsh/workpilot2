from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Baseline OWASP-recommended response headers for a JSON API.

    No Content-Security-Policy here: /docs and /redoc render Swagger
    UI/ReDoc, which load their own scripts/styles, and a strict CSP would
    break them. The browser-facing SPA (served separately, see
    frontend/nginx.conf) already sets a real CSP for the surface users
    actually render untrusted content in.
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        is_https = request.url.scheme == "https" or request.headers.get("x-forwarded-proto") == "https"
        if is_https:
            response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains"
        return response
