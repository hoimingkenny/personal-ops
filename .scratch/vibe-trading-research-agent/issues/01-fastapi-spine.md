# 01 — FastAPI Spine

## Goal

Create the minimum FastAPI foundation for Vibe Trading Research Agent.

## Scope

- Add Python project config, FastAPI app, and local verification commands.
- Add liveness/readiness endpoints.
- Add Alembic and PostgreSQL config.
- Add docker-compose Postgres for local development.
- Add empty module/package structure for workflow, ingestion, document, evidence, retrieval, agent, harness, evaluation, and API.

## Acceptance Criteria

- `ruff check .`, `mypy app`, and `pytest` pass.
- Local Postgres starts through docker-compose.
- App starts with the `local` runtime role.
- `/health/live` and `/health/ready` endpoints are exposed.

## Out Of Scope

- Agent execution.
- Document ingestion.
- AWS deployment validation.
