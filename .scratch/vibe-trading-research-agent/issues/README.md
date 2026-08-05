# Vibe Trading Research Agent Tickets

These tickets encode the newly agreed scope for the next implementation pass.

## MVP A — Digest-first agent workflow backend

1. `01-fastapi-spine.md` — FastAPI, Alembic, health endpoints, docker-compose Postgres
2. `02-workflow-orchestrator.md` — workflow runs, tasks, attempts, events, retries, replay state
3. `03-ingestion-document-workers.md` — financial news feeds and report/PDF URL ingestion
4. `04-evidence-retrieval-memory.md` — chunks, citations, Postgres FTS, source metadata
5. `05-skills-tools-registry.md` — skills, tool registry, typed tool-call logging
6. `06-bounded-agent-runtime.md` — bounded ReAct loop, agent definitions, limits, structured outputs
7. `07-digest-agents-quality-gates.md` — classifier/ranker, brief writer, citation verifier, digest composer
8. `08-research-api-sse.md` — digest/report APIs, workflow status, SSE progress
9. `09-aws-api-worker-scheduler.md` — ECS API/worker/scheduler roles, RDS, S3, EventBridge
10. `10-eval-benchmark-cost.md` — eval harness, k6 benchmarks, token/cost tracking
11. `11-readme-evidence.md` — portfolio case study, runbook evidence, incident notes

## Guardrails

- Digest-first, not chatbot-first.
- Financial content processing, not stock advice or trading.
- Multi-agent workflow, not swarm branding.
- Postgres FTS first; Redis/Milvus/OpenSearch/Mem0 only after measured need or explicit experiment.
