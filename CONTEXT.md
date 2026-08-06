# Vibe Trading Research Agent

A cloud-native AI agent workflow backend for source-backed trading research. It ingests public financial sources and user-provided reports, builds an evidence library, runs specialized async agents, verifies numeric and citation claims, and produces trading research artifacts with auditable provenance.

Decisions: [`docs/adr/README.md`](docs/adr/README.md). Active build spec (when created): [`.scratch/vibe-trading-research-agent/spec.md`](.scratch/vibe-trading-research-agent/spec.md).

## Build

**Python/FastAPI**:
The application stack for this project. CI runs `ruff`, `mypy`, and `pytest`; the Docker image runs the FastAPI app through Uvicorn.
_Avoid_: Spring Boot, Maven, Gradle, Java-first implementation.

## Product identity

**Target role**:
Backend / platform / AI agent infrastructure engineer. CV bullets lead with async workflows, retrieval, evaluation, cloud ownership, performance, and reliability.
_Avoid_: pure DevOps-only framing, pure IAM-only framing, thin AI-wrapper framing.

**Vibe Trading Research Agent**:
The product this repo ships: a self-hosted trading research agent/workspace. Trading research is the first workload; the reusable asset is the workflow, retrieval, evaluation, and agent runtime beneath it.
_Avoid_: finance chatbot, stock picker, trading bot, investment advice app.

**Trading researcher**:
The primary user: a person who wants to process market/news content, public filings, and company reports into source-backed research artifacts for market understanding.
_Avoid_: trading desk, portfolio manager, financial advisor.

**Trading research workload**:
The first use case for the platform: ingest filings, annual reports, transcripts, market/news content, and user-provided report URLs; extract evidence; answer document questions; and generate source-backed research artifacts.
_Avoid_: trading bot, automated order placement, portfolio management, buy/sell/hold advice.

**Source-backed research artifact**:
The core output: a structured digest, report brief, watchlist note, or later bull/bear analysis with citations to source documents, pages, sections, tables, or URLs.
_Avoid_: investment recommendation, uncited AI summary, chat transcript as the primary artifact.

**MVP input scope**:
Financial news feeds and user-provided company report or PDF URLs. The platform may ingest web pages and PDFs, but does not discover every filing source automatically in MVP.
_Avoid_: broker integrations, paid data providers, full SEC/HKEX crawler, real-time market data, portfolio import.

**Source registry**:
The governed catalog of sources the platform may ingest. Each source records type, region, sector, compliance tier, license notes, rate limit, freshness expectation, connector type, and enabled status.
_Avoid_: random web browsing, untracked scraping, assuming open-source connector code overrides source data terms.

**Research-workspace product**:
The product centers on a source-backed evidence library and generated research artifacts. Daily digest and report brief workflows come first; chat/Q&A may be added later on top of the same evidence store.
_Avoid_: chatbot-first design, chat transcript as output, one-question demo.

**Agent infrastructure core**:
Reusable backend runtime for durable agent workflows: task orchestration, typed tool calls, retrieval memory, evaluation gates, human review states, and cost/latency observability.
_Avoid_: one-off prompt chain, chatbot wrapper, untracked LLM call.

**Cloud demo**:
A short-lived, documented AWS deployment (ECS, ECR, RDS, Secrets Manager, EventBridge) used to prove end-to-end CI/CD. Tear down after capture; do not imply 24/7 production traffic.
_Avoid_: production environment, always-on AWS instance.

## Backend model

**Source connector**:
Pluggable adapter that fetches and normalizes one external source, such as a financial news feed, web article, report page, transcript, or PDF URL.
_Avoid_: trading exchange connector, broker integration.

**Pipeline worker**:
A deterministic backend worker that fetches, parses, chunks, stores, indexes, or publishes data. Pipeline workers do not make open-ended LLM judgments.
_Avoid_: calling every background job an agent.

**Agent worker**:
A bounded AI worker that makes judgment calls using retrieved evidence and produces typed, reviewable artifacts. Examples: classifier/ranker, brief writer, citation verifier, change detector.
_Avoid_: autonomous swarm member, free-form chatbot persona.

**Skill**:
A reusable capability an agent can invoke, such as document search, table extraction, metric extraction, citation verification, digest writing, or change comparison.
_Avoid_: vague talent, prompt fragment with no schema.

**Tool call**:
A logged, typed invocation of a backend capability by an agent or skill. Tool calls record input, output, duration, errors, model/prompt version where relevant, and cost.
_Avoid_: hidden LLM side effect, untracked API call.

**Bounded ReAct loop**:
A controlled Think-Act-Observe cycle where an agent may call allowed tools up to explicit limits for steps, latency, and cost before producing structured output.
_Avoid_: unbounded autonomous loop, agent that can call any tool.

**Multi-agent workflow**:
An orchestrated workflow where specialized agent workers collaborate through durable task state and shared evidence. It is controlled by the workflow orchestrator, not emergent free-form chat.
_Avoid_: swarm branding, autonomous agent society.

**Retrieval memory**:
Long-lived searchable knowledge: source documents, chunks, tables, metrics, news items, prior digests, and citation anchors.
_Avoid_: mystical agent memory, opaque chat history.

**Workflow memory**:
Durable per-run state: workflow tasks, task attempts, tool calls, events, intermediate artifacts, retries, and failures.
_Avoid_: in-memory-only context that disappears after a process restart.

**Evaluation memory**:
Stored quality history: failed citation checks, numeric mismatches, unsupported claims, human corrections, eval scores, and prompt/model version comparisons.
_Avoid_: manual vibes-based output review.

**Quality gate**:
An automated or human review check that must pass before a digest is published, such as citation coverage, numeric accuracy, schema validity, unsupported-claim detection, and cost/latency budgets.
_Avoid_: publishing raw LLM output directly.

**Runtime role**:
| Role | Runs as | Purpose |
|---------|---------|------|
| `local` | API + worker locally | Laptop / docker-compose |
| `api` | Web API only | ECS API service |
| `worker` | Background workers | ECS worker service |
| `scheduler` | Scheduled run trigger | EventBridge ECS RunTask |

## Cloud and delivery

**Pipeline deploy**:
GitHub Actions builds, scans, pushes to ECR, and updates ECS directly. The AWS demo default.
_Avoid_: manual deploy as the primary story; GitOps for AWS (GitOps is K8s scale-up — ADR 0001).

**Private subnet**:
Subnet with no direct internet ingress. ECS tasks and RDS live here; outbound traffic uses NAT or VPC endpoints.
_Avoid_: internal subnet (unless matching AWS console label).

**EventBridge scheduled workflow**:
EventBridge schedule → one-shot ECS Fargate RunTask with the `scheduler` runtime role. It creates ingestion or digest workflow runs; workers execute tasks asynchronously.
_Avoid_: CloudWatch Events (legacy name in conversation only — prefer EventBridge in CV/docs).

**Kubernetes deployment path**:
Later packaging for k3s/kind or EKS if the AWS ECS demo is already working and measured. Same container image and API/worker/scheduler split should carry over.
_Avoid_: implying Helm or Kubernetes exists in MVP.

## Git workflow

**Branch model**:
The repo uses a single long-lived branch (`main`) plus short-lived feature branches per ticket. GitHub Flow, light variant — every change lands on `main` via squash-merge PR.

_Avoid_: develop, release/*, hotfix/*, Git Flow variants.

**Release**:
A versioned tag on `main`, named with semantic versioning (e.g. `v0.1.0`, `v0.1.1`).
_Avoid_: "deploy markers", "release branches".

**Hotfix path**:
A short-lived `fix/*` branch off `main`, merged back via squash PR. Same flow as a feature branch — no separate release line.
