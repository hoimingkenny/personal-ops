# 02 — Workflow Run Tracer Bullet

**What to build:** A minimal durable workflow path. A user can create a workflow run through the API, a worker can claim and complete its tasks, and the API can show status, attempts, events, retries, failures, and terminal state.

**Blocked by:** 01 — FastAPI Spine And Local Runtime.

**Status:** ready-for-agent

- [ ] A workflow run can be created through an API request and persisted with an initial task.
- [ ] A worker can claim available tasks without two workers claiming the same task.
- [ ] A task can succeed, fail, retry within limits, and reach a terminal failure state when retries are exhausted.
- [ ] Workflow events record meaningful state transitions for run creation, task claim, task completion, retry, and failure.
- [ ] The API can return workflow status, current tasks, attempts, and recent events.
- [ ] Tests exercise the workflow through public API and worker boundaries rather than private helper methods.
