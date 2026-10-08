"""Authenticated lesson progress API. No service-role credentials are used."""
from contextlib import asynccontextmanager
from typing import Annotated

import httpx
import jwt
from jwt import PyJWKClient
from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    supabase_url: str = ""
    supabase_anon_key: str = ""
    supabase_jwt_audience: str = "authenticated"
    allowed_origins: str = ""
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()


class ProgressInput(BaseModel):
    lesson_id: str = Field(pattern=r"^[a-z0-9-]{1,64}$")
    completed: bool = True


class ProgressRecord(ProgressInput):
    updated_at: str | None = None


app = FastAPI(title="Myanmar AI Coding Academy API", version="0.1.0")


@app.get("/health")
async def health():
    return {"status": "ok"}


def config_ready() -> None:
    if not settings.supabase_url or not settings.supabase_anon_key:
        raise HTTPException(status_code=503, detail="Supabase is not configured")


async def current_user(authorization: Annotated[str | None, Header()] = None) -> tuple[str, str]:
    config_ready()
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Bearer token required")
    token = authorization[7:]
    try:
        jwks_url = settings.supabase_url.rstrip("/") + "/auth/v1/.well-known/jwks.json"
        signing_key = PyJWKClient(jwks_url, cache_jwk_set=True, lifespan=300).get_signing_key_from_jwt(token).key
        claims = jwt.decode(
            token,
            signing_key,
            algorithms=["RS256", "ES256"],
            audience=settings.supabase_jwt_audience,
            issuer=settings.supabase_url.rstrip("/") + "/auth/v1",
            options={"require": ["exp", "iat", "sub", "iss", "aud"]},
        )
        user_id = claims["sub"]
        if claims.get("role") != "authenticated":
            raise ValueError("Not an authenticated user")
        return user_id, token
    except Exception as exc:
        raise HTTPException(status_code=401, detail="Invalid or expired token") from exc


async def supabase_request(method: str, path: str, token: str, json_body: dict | None = None):
    headers = {
        "apikey": settings.supabase_anon_key,
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Prefer": "return=representation,resolution=merge-duplicates",
    }
    try:
        async with httpx.AsyncClient(timeout=12.0) as client:
            response = await client.request(
                method,
                settings.supabase_url.rstrip("/") + "/rest/v1/" + path,
                headers=headers,
                json=json_body,
            )
            response.raise_for_status()
            return response.json()
    except (httpx.HTTPError, ValueError) as exc:
        raise HTTPException(status_code=502, detail="Progress storage unavailable") from exc


@app.get("/api/v1/progress", response_model=list[ProgressRecord])
async def list_progress(auth: Annotated[tuple[str, str], Depends(current_user)]):
    user_id, token = auth
    # Supabase RLS independently restricts this request to the authenticated user's rows.
    result = await supabase_request(
        "GET", "lesson_progress?select=lesson_id,completed,updated_at&order=updated_at.desc", token
    )
    return result


@app.put("/api/v1/progress/{lesson_id}", response_model=ProgressRecord)
async def save_progress(
    lesson_id: str,
    auth: Annotated[tuple[str, str], Depends(current_user)],
):
    validated = ProgressInput(lesson_id=lesson_id)
    user_id, token = auth
    result = await supabase_request(
        "POST",
        "lesson_progress?on_conflict=user_id,lesson_id",
        token,
        {"user_id": user_id, "lesson_id": validated.lesson_id, "completed": True},
    )
    if not result:
        raise HTTPException(status_code=502, detail="No progress returned")
    return result[0]
