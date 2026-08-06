from typing import Literal

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

DatabaseState = Literal["ready", "not_configured", "unavailable"]


async def check_database(database_url: str | None) -> DatabaseState:
    if not database_url:
        return "not_configured"

    engine = create_async_engine(database_url, pool_pre_ping=True)
    try:
        async with engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
    except Exception:
        return "unavailable"
    finally:
        await engine.dispose()

    return "ready"
