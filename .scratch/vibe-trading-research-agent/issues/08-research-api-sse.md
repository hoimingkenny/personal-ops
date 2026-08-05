# 08 — Research API And SSE

## Goal

Expose workflow control, digest reads, search, and live progress.

## Scope

- Add REST endpoints for creating digest workflows, reading workflow status, reading digests, and searching evidence.
- Add SSE endpoint for workflow events.
- Use `202 Accepted` for async workflow creation.
- Add cursor or time-based pagination where result sets can grow.

## Acceptance Criteria

- `POST /api/digests` creates a workflow run and returns status URL.
- `GET /api/workflow-runs/{id}/events` streams workflow events via SSE.
- `GET /api/digests/{id}` returns published digest artifacts only.
- HTTP semantics are covered by API integration tests.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Senior Signal

The API models asynchronous work explicitly instead of blocking on long agent runs.
