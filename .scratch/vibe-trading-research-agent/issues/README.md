# Vibe Trading Research Agent Tickets

Status: ready-for-agent

These tickets implement the approved spec as tracer-bullet slices. Each ticket should leave a demoable or externally verifiable behavior behind.

## MVP A — Source-backed trading research workflow

1. `01-fastapi-spine-and-local-runtime.md` — runnable FastAPI app, local runtime, health checks, migrations, and verification tooling
2. `02-secret-provider-and-vault-foundation.md` — pluggable secret provider boundary with HashiCorp Vault prioritized before workflow work
3. `03-workflow-run-tracer-bullet.md` — create, claim, execute, retry, and inspect durable workflow runs
4. `04-source-registry-and-news-ingestion.md` — governed source registry plus idempotent fixture news ingestion
5. `05-report-url-to-evidence-library.md` — report/PDF URL ingestion into citation-ready evidence
6. `06-evidence-search-api.md` — Postgres full-text evidence search with metadata and citation anchors
7. `07-skills-and-tool-execution-registry.md` — typed skill/tool contracts with tool-call logging
8. `08-bounded-agent-runtime.md` — bounded ReAct-style agent execution with limits and structured output
9. `09-digest-workflow-tracer-bullet.md` — end-to-end draft digest workflow over source-backed evidence
10. `10-citation-and-numeric-quality-gates.md` — publish/needs-review decision from citation and numeric checks
11. `11-research-api-and-sse-progress.md` — workflow creation, artifact reads, quality results, and SSE progress
12. `12-evaluation-replay-cost-and-benchmarks.md` — golden evals, replay, latency/cost metrics, and benchmark evidence
13. `13-aws-api-worker-scheduler-demo.md` — ECS API/worker/scheduler demo with RDS, S3, EventBridge, logs, and smoke tests
14. `14-portfolio-evidence-and-readme.md` — README, sample artifacts, eval/benchmark results, cloud proof, and CV framing

## Guardrails

- Digest-first, not chatbot-first.
- Financial content processing, not stock advice or trading.
- Multi-agent workflow through durable orchestration, not swarm branding.
- HashiCorp Vault is used for secret-provider depth, not as a reason to delay the research workflow indefinitely.
- Postgres FTS first; Redis, Milvus, OpenSearch, pgvector, and Mem0 only after measured need or explicit experiment.
