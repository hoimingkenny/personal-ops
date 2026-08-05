# 08 — Digest Workflow Tracer Bullet

**What to build:** The first end-to-end draft digest workflow over source-backed evidence. A user can request a digest, the system can select candidate evidence, run bounded agent steps, and store a draft research artifact.

**Blocked by:** 07 — Bounded Agent Runtime.

**Status:** ready-for-agent

- [ ] A digest workflow can be created from a time window or source selection.
- [ ] Candidate news/report evidence can be retrieved and ranked for digest inclusion.
- [ ] A classifier/ranker step produces structured item classifications and scores.
- [ ] A brief writer step produces draft digest sections from selected evidence.
- [ ] The draft artifact stores sections, cited evidence references, workflow run id, and generation metadata.
- [ ] Tests exercise the digest workflow as a user-visible path from request to draft artifact.
