import uuid

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from jose import JWTError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.config import settings
from app.core.rate_limit import check_and_increment, reset as reset_rate_limit
from app.core.security import create_access_token, create_refresh_token, decode_token, hash_password, verify_password
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, SignupRequest, TokenResponse, UserOut
from app.schemas.settings import PasswordChange, ProfileUpdate
from app.services import auth as auth_service

router = APIRouter(prefix="/auth", tags=["auth"])

_REFRESH_COOKIE_NAME = "refresh_token"
_REFRESH_COOKIE_PATH = f"{settings.api_v1_prefix}/auth"


def _set_refresh_cookie(response: Response, user_id: uuid.UUID) -> None:
    response.set_cookie(
        key=_REFRESH_COOKIE_NAME,
        value=create_refresh_token(user_id),
        httponly=True,
        secure=settings.cookie_secure,
        samesite="lax",
        max_age=settings.refresh_token_expire_days * 24 * 60 * 60,
        path=_REFRESH_COOKIE_PATH,
    )


@router.post("/signup", response_model=UserOut, status_code=201)
def signup(data: SignupRequest, db: Session = Depends(get_db)) -> UserOut:
    user = auth_service.signup(db, data)
    return UserOut.model_validate(user)


@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest, response: Response, db: Session = Depends(get_db)) -> TokenResponse:
    # Keyed by email (not IP): in this deployment all traffic can share an
    # IP behind a proxy, and the goal is to slow down guessing against one
    # account regardless of where the requests originate.
    rate_key = f"login_attempts:{data.email.lower()}"
    if not check_and_increment(
        rate_key, settings.login_rate_limit_attempts, settings.login_rate_limit_window_seconds
    ):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Please try again later.",
        )

    user = auth_service.authenticate(db, data)
    reset_rate_limit(rate_key)

    token = auth_service.issue_access_token(user)
    _set_refresh_cookie(response, user.id)
    return TokenResponse(access_token=token)


@router.post("/refresh", response_model=TokenResponse)
def refresh(request: Request, response: Response, db: Session = Depends(get_db)) -> TokenResponse:
    raw_token = request.cookies.get(_REFRESH_COOKIE_NAME)
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired refresh token"
    )
    if raw_token is None:
        raise credentials_exception

    try:
        payload = decode_token(raw_token)
        if payload.get("type") != "refresh":
            raise credentials_exception
        user_id = uuid.UUID(payload["sub"])
    except (JWTError, KeyError, ValueError) as exc:
        raise credentials_exception from exc

    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise credentials_exception

    # Rotate the refresh token on every use so a leaked-but-unused token has
    # a shrinking window of validity.
    _set_refresh_cookie(response, user.id)
    access_token = create_access_token(user_id=user.id, organization_id=user.organization_id, role=user.role.value)
    return TokenResponse(access_token=access_token)


@router.post("/logout")
def logout(response: Response) -> dict[str, str]:
    response.delete_cookie(_REFRESH_COOKIE_NAME, path=_REFRESH_COOKIE_PATH)
    return {"detail": "logged out"}


@router.get("/me", response_model=UserOut)
def me(current_user=Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(current_user)


@router.patch("/me", response_model=UserOut)
def update_me(
    data: ProfileUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)
) -> UserOut:
    current_user.full_name = data.full_name
    db.commit()
    db.refresh(current_user)
    return UserOut.model_validate(current_user)


@router.post("/me/change-password")
def change_password(
    data: PasswordChange, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)
) -> dict[str, str]:
    if not verify_password(data.current_password, current_user.hashed_password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Current password is incorrect")
    current_user.hashed_password = hash_password(data.new_password)
    db.commit()
    return {"detail": "password changed"}
