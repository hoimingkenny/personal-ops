# 01 — FastAPI Spine And Local Runtime

**What to build:** A runnable FastAPI foundation for Vibe Trading Research Agent. A developer can install dependencies, run the API locally, connect to local PostgreSQL, run migrations, verify health endpoints, and execute lint, type checks, and tests.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] A local developer can start the FastAPI API and receive successful liveness and readiness responses.
- [ ] Local PostgreSQL can be started for development and used by the app configuration.
- [ ] Alembic is configured and can run an initial empty or baseline migration.
- [ ] Runtime roles for local, API, worker, and scheduler are represented in configuration even if later roles are placeholders.
- [ ] The app has a clear package/module shape for workflow, source ingestion, evidence, retrieval, skills/tools, agents, harness, evaluation, and API concerns.
- [ ] CI-compatible commands for linting, typing, and tests pass.
- [ ] The Docker image can run the FastAPI app through Uvicorn and expose the same health endpoints.
