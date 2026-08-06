# 04 — Report URL To Evidence Library

**What to build:** A report/PDF ingestion path that turns a user-provided document URL into citation-ready evidence. A user can submit a report URL, run the workflow, and inspect extracted chunks and anchors that later agents can cite.

**Blocked by:** 02 — Workflow Run Tracer Bullet.

**Status:** ready-for-agent

- [ ] A report or PDF URL can be accepted as workflow input and recorded with provenance.
- [ ] The raw document artifact is stored in local development storage and can later map to S3 in AWS.
- [ ] Text extraction creates document sections or chunks with stable citation anchors.
- [ ] Extracted evidence records preserve document metadata, source URL, chunk ordering, and page or section information when available.
- [ ] Failed fetches or parse failures are represented as workflow task failures with useful error events.
- [ ] Tests use stable fixtures and assert externally visible evidence records, not parser internals.
