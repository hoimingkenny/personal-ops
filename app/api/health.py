from typing import Literal, TypedDict

from fastapi import APIRouter, Response, status

from app.core.settings import RuntimeRole, get_settings
from app.db.readiness import check_database

router = APIRouter(prefix="/health", tags=["health"])


class LiveResponse(TypedDict):
    service: str
    status: Literal["live"]


class ReadyChecks(TypedDict):
    database: Literal["ready", "not_configured", "unavailable"]


class ReadyResponse(TypedDict):
    service: str
    status: Literal["ready", "degraded"]
    runtime_role: str
    checks: ReadyChecks


@router.get("/live")
async def live() -> LiveResponse:
    settings = get_settings()
    return {"service": settings.service_name, "status": "live"}


@router.get("/ready")
async def ready(response: Response) -> ReadyResponse:
    settings = get_settings()
    database_state = await check_database(settings.database_url)
    local_without_database = (
        settings.runtime_role is RuntimeRole.LOCAL and database_state == "not_configured"
    )
    service_status: Literal["ready", "degraded"] = (
        "ready" if database_state == "ready" or local_without_database else "degraded"
    )
    if service_status == "degraded":
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE

    return {
        "service": settings.service_name,
        "status": service_status,
        "runtime_role": settings.runtime_role.value,
        "checks": {"database": database_state},
    }
