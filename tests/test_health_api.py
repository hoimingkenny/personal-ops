from fastapi.testclient import TestClient

from app.core.settings import get_settings
from app.main import app


def test_liveness_reports_service_identity() -> None:
    client = TestClient(app)

    response = client.get("/health/live")

    assert response.status_code == 200
    assert response.json() == {
        "service": "vibe-trading-research-agent",
        "status": "live",
    }


def test_readiness_reports_runtime_role_and_database_state() -> None:
    client = TestClient(app)

    response = client.get("/health/ready")

    assert response.status_code == 200
    assert response.json() == {
        "service": "vibe-trading-research-agent",
        "status": "ready",
        "runtime_role": "local",
        "checks": {"database": "not_configured"},
    }


def test_readiness_fails_for_api_role_without_database_url(monkeypatch) -> None:
    monkeypatch.setenv("APP_ROLE", "api")
    monkeypatch.delenv("DATABASE_URL", raising=False)
    get_settings.cache_clear()
    client = TestClient(app)

    try:
        response = client.get("/health/ready")
    finally:
        get_settings.cache_clear()

    assert response.status_code == 503
    assert response.json() == {
        "service": "vibe-trading-research-agent",
        "status": "degraded",
        "runtime_role": "api",
        "checks": {"database": "not_configured"},
    }
