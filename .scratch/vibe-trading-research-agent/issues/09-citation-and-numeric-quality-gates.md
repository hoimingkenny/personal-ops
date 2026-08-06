# 09 — Citation And Numeric Quality Gates

**What to build:** Quality gates that decide whether a draft digest or report brief is safe to publish. Draft artifacts are checked for schema validity, citation coverage, unsupported claims, and numeric accuracy, then marked published or needs review.

**Blocked by:** 08 — Digest Workflow Tracer Bullet.

**Status:** ready-for-agent

- [ ] Draft artifacts are validated against their required output schema.
- [ ] Citation coverage is computed for claims that require source support.
- [ ] Unsupported high-severity claims prevent automatic publication.
- [ ] Numeric claims are compared against cited evidence with explicit tolerance.
- [ ] Artifacts move through draft, quality-gate-failed, needs-review, approved, and published states as applicable.
- [ ] Tests cover passing gates, missing citations, unsupported claims, numeric mismatch, and needs-review outcomes.
