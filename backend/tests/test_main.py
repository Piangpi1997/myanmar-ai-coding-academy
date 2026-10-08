from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_progress_requires_auth_or_config():
    response = client.get("/api/v1/progress")
    assert response.status_code in (401, 503)

def test_invalid_lesson_id_rejected():
    response = client.put("/api/v1/progress/INVALID LESSON")
    assert response.status_code in (401, 422, 503)
