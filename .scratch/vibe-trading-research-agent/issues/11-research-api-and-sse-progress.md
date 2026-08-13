# 11 — Research API And SSE Progress

**What to build:** The user-facing research API and progress stream. A client can create research workflows, read artifacts and quality results, inspect workflow status, and subscribe to workflow progress through server-sent events.

**Blocked by:** 10 — Citation And Numeric Quality Gates.

**Status:** ready-for-agent

- [ ] The API can create digest or report-brief workflow runs from supported inputs.
- [ ] The API can return workflow status, events, attempts, and terminal outcome.
- [ ] The API can return draft, needs-review, and published artifacts with quality gate results.
- [ ] An SSE endpoint streams workflow progress events in order for a workflow run.
- [ ] SSE clients can observe terminal success or failure without aggressive polling.
- [ ] Tests cover API contracts, artifact reads, quality result reads, and SSE event ordering.
