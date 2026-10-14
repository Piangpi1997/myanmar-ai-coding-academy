from datetime import datetime, timedelta, timezone
from pathlib import Path
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from app import auth, study
from app.main import app

USER = "12345678-1234-1234-1234-123456789012"
OTHER = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"


@pytest.fixture
def client(monkeypatch):
    app.dependency_overrides[auth.current_user] = lambda: (USER, "user-token")
    monkeypatch.setattr(study.settings, "supabase_url", "https://test.supabase.co")
    monkeypatch.setattr(study.settings, "supabase_anon_key", "test-public-key")
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def payload(**overrides):
    data = {
        "client_id": str(uuid4()),
        "started_at": datetime.now(timezone.utc).isoformat(),
        "duration_seconds": 60,
        "activity": "lesson",
        "lesson_id": "py-01",
    }
    data.update(overrides)
    return data


def fake_storage(monkeypatch):
    rows = {}
    queries = []

    async def store(method, path, token, body=None, prefer="return=representation,resolution=merge-duplicates"):
        queries.append((method, path, token, body, prefer))
        if method == "POST":
            assert token == "user-token"
            key = (body["user_id"], body["client_id"])
            if key in rows:
                return []
            row = {**body, "created_at": datetime.now(timezone.utc).isoformat()}
            rows[key] = row
            return [row.copy()]
        owner = USER
        if "user_id=eq." + OTHER in path:
            owner = OTHER
        matches = [row.copy() for (user_id, _), row in rows.items() if user_id == owner]
        if "client_id=eq." in path:
            client_id = path.split("client_id=eq.", 1)[1].split("&", 1)[0]
            matches = [row for row in matches if row["client_id"] == client_id]
        return matches

    monkeypatch.setattr(study, "storage", store)
    return rows, queries


def test_study_history_requires_authentication():
    with TestClient(app) as unauthenticated:
        assert unauthenticated.get("/api/v1/study/sessions").status_code == 401


def test_session_insert_derives_owner_from_verified_jwt(client, monkeypatch):
    rows, queries = fake_storage(monkeypatch)
    response = client.post("/api/v1/study/sessions", json=payload())
    assert response.status_code == 200
    body = response.json()
    assert "user_id" not in body
    assert (USER, body["client_id"]) in rows
    assert queries[0][1] == "study_sessions?on_conflict=user_id,client_id"
    assert queries[0][4] == "return=representation,resolution=ignore-duplicates"


def test_history_filters_by_verified_owner(client, monkeypatch):
    _, queries = fake_storage(monkeypatch)
    response = client.get("/api/v1/study/sessions?limit=10")
    assert response.status_code == 200 and response.json() == []
    assert "user_id=eq." + USER in queries[-1][1]
    assert "limit=10" in queries[-1][1]
    assert queries[-1][2] == "user-token"


def test_client_cannot_choose_owner_or_send_unknown_fields(client):
    assert client.post("/api/v1/study/sessions", json=payload(user_id=OTHER)).status_code == 422
    assert client.post("/api/v1/study/sessions", json=payload(extra="not allowed")).status_code == 422


@pytest.mark.parametrize("changes", [
    {"duration_seconds": 0},
    {"duration_seconds": 86401},
    {"activity": "admin"},
    {"lesson_id": "Invalid ID"},
    {"started_at": "2026-10-15T12:00:00"},
])
def test_invalid_session_data_is_rejected(client, changes):
    assert client.post("/api/v1/study/sessions", json=payload(**changes)).status_code == 422


def test_future_sessions_are_rejected(client):
    future = (datetime.now(timezone.utc) + timedelta(minutes=10)).isoformat()
    assert client.post("/api/v1/study/sessions", json=payload(started_at=future)).status_code == 422


def test_replayed_checkpoint_is_idempotent_and_changed_replay_conflicts(client, monkeypatch):
    fake_storage(monkeypatch)
    request = payload()
    first = client.post("/api/v1/study/sessions", json=request)
    second = client.post("/api/v1/study/sessions", json=request)
    assert first.status_code == second.status_code == 200
    assert first.json() == second.json()
    assert client.post(
        "/api/v1/study/sessions", json={**request, "duration_seconds": 90}
    ).status_code == 409


def test_duplicate_client_id_is_scoped_by_owner(client, monkeypatch):
    rows, _ = fake_storage(monkeypatch)
    request = payload()
    saved = client.post("/api/v1/study/sessions", json=request).json()
    foreign = {**saved, "user_id": OTHER, "duration_seconds": 90}
    rows[(OTHER, saved["client_id"])] = foreign
    again = client.post("/api/v1/study/sessions", json=request)
    assert again.status_code == 200
    assert again.json()["duration_seconds"] == request["duration_seconds"]


def test_study_migration_keeps_data_private_and_owner_scoped():
    root = Path(__file__).resolve().parents[2]
    sql = (root / "database/migrations/006_study_sessions.sql").read_text()
    normalized = " ".join(sql.lower().split())
    assert "alter table public.study_sessions enable row level security" in normalized
    assert "revoke all on public.study_sessions from anon, authenticated" in normalized
    assert "unique (user_id, client_id)" in normalized
    assert 'for select to authenticated using (user_id = (select auth.uid()))' in normalized
    assert 'for insert to authenticated with check (user_id = (select auth.uid()))' in normalized
    assert 'for delete to authenticated using (user_id = (select auth.uid()))' in normalized
