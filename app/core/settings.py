from enum import StrEnum
from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class RuntimeRole(StrEnum):
    LOCAL = "local"
    API = "api"
    WORKER = "worker"
    SCHEDULER = "scheduler"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    service_name: str = "vibe-trading-research-agent"
    runtime_role: RuntimeRole = Field(default=RuntimeRole.LOCAL, alias="APP_ROLE")
    database_url: str | None = Field(default=None, alias="DATABASE_URL")


@lru_cache
def get_settings() -> Settings:
    return Settings()
