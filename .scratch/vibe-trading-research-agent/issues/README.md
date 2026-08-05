# Vibe Trading Research Agent Tickets

Status: ready-for-agent

These tickets implement the approved spec as tracer-bullet slices. Each ticket should leave a demoable or externally verifiable behavior behind.

## MVP A — Source-backed trading research workflow

1. `01-fastapi-spine-and-local-runtime.md` — runnable FastAPI app, local runtime, health checks, migrations, and verification tooling
2. `02-workflow-run-tracer-bullet.md` — create, claim, execute, retry, and inspect durable workflow runs
3. `03-source-registry-and-news-ingestion.md` — governed source registry plus idempotent fixture news ingestion
4. `04-report-url-to-evidence-library.md` — report/PDF URL ingestion into citation-ready evidence
5. `05-evidence-search-api.md` — Postgres full-text evidence search with metadata and citation anchors
6. `06-skills-and-tool-execution-registry.md` — typed skill/tool contracts with tool-call logging
7. `07-bounded-agent-runtime.md` — bounded ReAct-style agent execution with limits and structured output
8. `08-digest-workflow-tracer-bullet.md` — end-to-end draft digest workflow over source-backed evidence
9. `09-citation-and-numeric-quality-gates.md` — publish/needs-review decision from citation and numeric checks
10. `10-research-api-and-sse-progress.md` — workflow creation, artifact reads, quality results, and SSE progress
11. `11-evaluation-replay-cost-and-benchmarks.md` — golden evals, replay, latency/cost metrics, and benchmark evidence
12. `12-aws-api-worker-scheduler-demo.md` — ECS API/worker/scheduler demo with RDS, S3, EventBridge, logs, and smoke tests
13. `13-portfolio-evidence-and-readme.md` — README, sample artifacts, eval/benchmark results, cloud proof, and CV framing

## Guardrails

- Digest-first, not chatbot-first.
- Financial content processing, not stock advice or trading.
- Multi-agent workflow through durable orchestration, not swarm branding.
- Postgres FTS first; Redis, Milvus, OpenSearch, pgvector, and Mem0 only after measured need or explicit experiment.
