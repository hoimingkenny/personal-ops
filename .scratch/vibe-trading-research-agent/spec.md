# Vibe Trading Research Agent — Build Spec

**Status:** draft-ready-for-ticketing

**Feature slug:** `vibe-trading-research-agent`

**Authoritative decisions:** [`docs/adr/README.md`](../../docs/adr/README.md), [`CONTEXT.md`](../../CONTEXT.md), [`docs/spec/agent-harness.md`](../../docs/spec/agent-harness.md)

---

## Problem Statement

Trading research is noisy: market news, company reports, filings, transcripts, and public macro sources are scattered, duplicated, and easy to misread when summarized by generic AI tools. The hard problem is not producing prose; it is building a replayable, observable pipeline that ingests governed public sources, extracts source-backed evidence, coordinates bounded agents, verifies claims, and publishes research artifacts with measurable quality, latency, and cost.

## Solution

Vibe Trading Research Agent is a cloud-native AI agent workflow backend for source-backed trading research. It ingests curated public financial sources and user-provided report/PDF URLs, stores raw and processed evidence, retrieves relevant chunks/tables, coordinates specialized agent workers, verifies citation/numeric claims, and publishes source-backed research artifacts such as daily digests and report briefs.

The first workflows are financial news digest generation and report brief generation. The reusable asset is the agent infrastructure core: workflow orchestration, Skills-Agent separation, bounded ReAct loops, typed tool execution, memory stores, quality gates, and observability.

## Product Boundaries

### In scope

- Source registry with source compliance tiers.
- Public financial news feed ingestion.
- User-provided company report / PDF URL ingestion.
- Source-backed digest, report brief, and research note generation.
- PostgreSQL-backed workflow state, evidence metadata, and full-text retrieval.
- S3 artifact storage for raw documents, extracted text/tables, generated digests, and eval exports.
- Deterministic pipeline workers for ingestion, parsing, chunking, indexing, and publishing.
- Agent workers for classification/ranking, brief writing, citation verification, and digest composition.
- Bounded ReAct loop with max tool calls, latency, cost, allowed tools, and structured output.
- Skills and tool registry with typed tool-call logging.
- Retrieval memory, workflow memory, and evaluation memory.
- Quality gates for citation coverage, numeric accuracy, schema validity, unsupported claims, and cost/latency budgets.
- REST APIs for digest/report reads and workflow control.
- SSE endpoint for workflow progress.
- AWS demo with ECS API/worker/scheduler, RDS, S3, EventBridge, Secrets Manager, CloudWatch, ECR, ALB, Terraform, and GitHub Actions OIDC.

### Out of scope

- Stock recommendations, buy/sell/hold advice, price targets, trading bot, automated order placement.
- Broker integrations, portfolio import, paid market data providers, real-time prices.
- Full SEC/HKEX crawler in MVP.
- Chatbot-first UX.
- Free-form swarm branding or autonomous agent society.
- MCP server, Mem0, Milvus, Redis, OpenSearch, multimodal/VLM extraction, custom model training, Kubernetes/Helm in MVP.

## Core Workflow

```
digest requested or scheduled
→ create workflow run
→ ingest sources
→ parse and chunk documents
→ index evidence
→ classify and rank candidate items
→ draft digest sections
→ verify citations and numeric claims
→ compose digest
→ publish artifact
```

## Logical Modules

| Module | Responsibility |
|--------|----------------|
| Source ingestion | Fetch news feeds and provided report/PDF URLs idempotently. |
| Document processing | Extract text, sections, chunks, tables, and citation anchors. |
| Evidence store | Persist source-backed chunks, tables, metrics, citations, and artifact pointers. |
| Retrieval | Search evidence with Postgres FTS, metadata filters, and ranking. |
| Workflow orchestrator | Own workflow runs, tasks, attempts, retries, replay, and events. |
| Agent runtime | Execute bounded agents with allowed skills/tools, schemas, budgets, and versions. |
| Tool execution layer | Execute and log typed tool calls. |
| Evaluation harness | Run citation, numeric, schema, unsupported-claim, latency, and cost checks. |
| Digest publisher | Publish source-backed digest artifacts. |
| Research API | Expose workflow, digest, search, and SSE endpoints. |

## MVP Agent Architecture

### Deterministic workers

- **Ingestion Worker**: fetch RSS/news/PDF URL, store raw artifact and metadata.
- **Document Worker**: extract text/chunks/metadata/citation anchors.
- **Indexing Worker**: write searchable evidence records.

### Agent workers

- **Classifier/Ranker Agent**: classify items and score importance, novelty, source quality, and relevance.
- **Brief Writer Agent**: generate digest sections from selected evidence.
- **Citation Verifier Agent**: validate claims against source evidence and flag unsupported/numeric mismatches.

## Harness

The harness contract is defined in [`docs/spec/agent-harness.md`](../../docs/spec/agent-harness.md). MVP implementation should treat that document as the source of truth for capability YAML, bounded ReAct limits, tool-call logging, quality gates, eval cases, replay, and publish states.

## AWS Runtime

Use one FastAPI/Python codebase and image with separate runtime roles:

| Runtime role | Role |
|--------------|------|
| `local` | API and worker locally with docker-compose Postgres. |
| `api` | ECS API service for REST/SSE and digest reads. |
| `worker` | ECS worker service for pipeline and agent task execution. |
| `scheduler` | EventBridge-triggered ECS RunTask that creates scheduled workflow runs and exits. |

## Senior Evidence

- Workflow/task tables show durable async orchestration and replayability.
- Tool-call logs show typed tool execution, cost, latency, errors, and model/prompt versions.
- Retrieval/evaluation memory proves source grounding and quality history.
- SSE progress proves application-level protocol design beyond basic REST.
- Eval harness produces citation/numeric accuracy metrics.
- Benchmarks document search/digest API P95/P99 and cost per digest before adding heavier infra.
- AWS demo evidence proves cloud ownership without claiming production scale.

## Open Items For Ticketing

- Exact first news sources.
- Minimum PDF parsing library and fallback policy.
- Whether MVP stores table extraction as raw tables only or normalizes metrics.
- First quality gate thresholds.
- Whether human review state is MVP A or A′.
