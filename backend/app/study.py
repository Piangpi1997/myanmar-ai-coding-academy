"""Private, owner-scoped study-session history; durations are client-reported foreground time."""
from datetime import datetime, timezone
from typing import Annotated, Literal
from uuid import UUID

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, ConfigDict, Field, field_validator

from .auth import current_user
from .config import settings

router = APIRouter(prefix="/api/v1/study", tags=["study"])


class StudySessionInput(BaseModel):
    model_config = ConfigDict(extra="forbid")

    client_id: UUID
    started_at: datetime
    duration_seconds: int = Field(ge=1, le=86_400)
    activity: Literal["lesson", "coding", "review"]
    lesson_id: str | None = Field(default=None, pattern=r"^[a-z0-9-]{1,64}$")

    @field_validator("started_at")
    @classmethod
    def require_timezone(cls, value: datetime) -> datetime:
        if value.tzinfo is None or value.utcoffset() is None:
            raise ValueError("started_at must include a timezone")
        if value.astimezone(timezone.utc).timestamp() > datetime.now(timezone.utc).timestamp() + 300:
            raise ValueError("started_at cannot be in the future")
        return value


class StudySessionRecord(StudySessionInput):
    model_config = ConfigDict(extra="ignore")
    created_at: datetime | None = None


async def storage(method: str, path: str, token: str, body: dict | None = None,
                  prefer: str = "return=representation,resolution=merge-duplicates") -> list[dict]:
    """Call PostgREST with the caller's JWT so RLS remains an independent boundary."""
    if not settings.supabase_url or not settings.supabase_anon_key:
        raise HTTPException(503, "Study history storage is not configured")
    headers = {
        "apikey": settings.supabase_anon_key,
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Prefer": prefer,
    }
    try:
        async with httpx.AsyncClient(timeout=12, follow_redirects=False, trust_env=False) as client:
            response = await client.request(
                method,
                settings.supabase_url.rstrip("/") + "/rest/v1/" + path,
                headers=headers,
                json=body,
            )
            if response.status_code in (401, 403):
                raise HTTPException(401, "Session expired or access denied")
            response.raise_for_status()
            if not response.content:
                return []
            result = response.json()
            if not isinstance(result, list):
                raise ValueError("Unexpected storage response")
            return result
    except HTTPException:
        raise
    except (httpx.HTTPError, ValueError):
        raise HTTPException(502, "Study history storage unavailable") from None


@router.get("/sessions", response_model=list[StudySessionRecord])
async def list_sessions(
    auth: Annotated[tuple[str, str], Depends(current_user)],
    limit: Annotated[int, Query(ge=1, le=500)] = 200,
):
    user_id, token = auth
    rows = await storage(
        "GET",
        "study_sessions?user_id=eq." + user_id
        + "&select=client_id,started_at,duration_seconds,activity,lesson_id,created_at"
        + "&order=started_at.desc&limit=" + str(limit),
        token,
    )
    return rows


@router.post("/sessions", response_model=StudySessionRecord)
async def save_session(
    session: StudySessionInput,
    auth: Annotated[tuple[str, str], Depends(current_user)],
):
    user_id, token = auth
    payload = session.model_dump(mode="json")
    payload["user_id"] = user_id  # Never trust client-supplied ownership.
    rows = await storage(
        "POST",
        "study_sessions?on_conflict=user_id,client_id",
        token,
        payload,
        prefer="return=representation,resolution=ignore-duplicates",
    )
    if rows:
        return rows[0]

    # A duplicate checkpoint is idempotent. Reject reuse of its ID with changed data.
    existing = await storage(
        "GET",
        "study_sessions?user_id=eq." + user_id
        + "&client_id=eq." + str(session.client_id)
        + "&select=client_id,started_at,duration_seconds,activity,lesson_id,created_at&limit=1",
        token,
    )
    if not existing:
        raise HTTPException(502, "Study session was not saved")
    stored = existing[0]
    expected_started_at = session.started_at.astimezone(timezone.utc)
    try:
        actual_started_at = datetime.fromisoformat(stored["started_at"].replace("Z", "+00:00"))
    except (KeyError, AttributeError, ValueError):
        raise HTTPException(502, "Study history storage unavailable") from None
    if (
        actual_started_at.astimezone(timezone.utc) != expected_started_at
        or stored.get("duration_seconds") != session.duration_seconds
        or stored.get("activity") != session.activity
        or stored.get("lesson_id") != session.lesson_id
    ):
        raise HTTPException(409, "Study session ID already belongs to different data")
    return stored
