# 02 — Workflow Orchestrator

## Goal

Implement durable workflow state before adding agent behaviour.

## Scope

- Add Alembic tables for workflow runs, workflow tasks, task attempts, and workflow events.
- Implement task state transitions, retries, timeouts, and replay metadata.
- Add deterministic task claiming with PostgreSQL transactions.
- Add integration tests for concurrent task claiming.

## Acceptance Criteria

- Workflow runs can be created, queried, completed, failed, and replay-marked.
- Workers can claim pending tasks without duplicate execution under concurrency.
- Task attempts and events are persisted for debugging.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Senior Signal

Agent work is durable and observable, not hidden inside one HTTP request.
