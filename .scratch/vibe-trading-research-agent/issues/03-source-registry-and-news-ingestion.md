# 03 — Source Registry And News Ingestion

**What to build:** A governed source registry and the first idempotent news ingestion path. A developer can register or seed a public financial news source, run an ingestion workflow, and inspect stored source metadata and raw news artifacts with provenance.

**Blocked by:** 02 — Workflow Run Tracer Bullet.

**Status:** ready-for-agent

- [ ] Sources record type, region, sector, compliance tier, license notes, rate limit, freshness expectation, connector type, and enabled state.
- [ ] A fixture or stable public RSS/news source can be ingested through a workflow task.
- [ ] Re-running ingestion for the same source does not duplicate already-seen items.
- [ ] Raw news item metadata is persisted with source URL, fetched time, normalized title, published time when available, and provenance.
- [ ] Disabled sources are not ingested by scheduled or manual ingestion workflows.
- [ ] Tests prove idempotency, source enablement, and provenance using fixture data.
