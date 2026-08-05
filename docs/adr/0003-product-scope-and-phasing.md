# Product scope and phasing

Vibe Trading Research Agent is a **cloud-native AI agent workflow backend** for source-backed trading research. The first product surface is a self-hosted research workspace with digest and report brief workflows; the durable CV signal is the agent infrastructure beneath it.

**Target role:** backend / platform / AI agent infrastructure engineer. CV leads with async workflows, typed tool execution, retrieval memory, evaluation gates, cloud deployment, observability, and performance/cost discipline.

## MVP A (build first)

**In scope:** FastAPI API, RDS-backed workflow/task state, deterministic pipeline workers, bounded agent workers, Skills-Agent separation, typed tool calls, source ingestion from public financial sources and user-provided report/PDF URLs, source registry, source compliance tiers, document chunking, PostgreSQL full-text retrieval, evidence library, source-backed digest/report brief generation, citation verification quality gate, SSE workflow progress, Alembic migrations, Docker, Terraform AWS demo, ECS API/worker/scheduler roles, S3 artifacts, EventBridge scheduled workflows, Secrets Manager, CloudWatch logs, GitHub Actions OIDC, Trivy, README/evidence.

**Out of scope:** stock recommendations, buy/sell/hold advice, trading bot, broker integrations, portfolio import, paid market data providers, full SEC/HKEX crawler, real-time market prices, chatbot-first UI, free-form autonomous swarm, MCP server, Mem0, Milvus, Redis, OpenSearch, multimodal/VLM extraction, custom model training, Kubernetes/Helm.

**Why research-workspace first:** A source-backed evidence library plus digest/report brief workflows is concrete enough to evaluate, cite, replay, and benchmark. Chat/Q&A can be added later on top of the same evidence store, but a chatbot-first MVP would look like a thin AI wrapper.

**Why trading research:** Trading research needs fast processing of public market/news context and company documents, but should not become order execution or stock picking. The workload has messy documents, tables, numbers, source ambiguity, and high need for citation discipline, which naturally exercises retrieval, extraction, verification, and agent orchestration.

## MVP A′ (agent infrastructure depth)

Add depth only after MVP A can generate and verify source-backed research artifacts:

- agent/skill YAML capability definitions
- evaluation harness with golden cases for citation coverage, numeric accuracy, unsupported claims, and schema validity
- human review states: draft → needs review → approved → published
- cost/latency tracking by workflow, agent, model, and tool
- k6 benchmarks for search, digest read, and workflow status APIs
- query-plan/index tuning for retrieval and workflow tables
- Redis cache only if benchmarks justify it

Honest CV framing: numbers come from measured benchmarks and eval runs in this repo, not copied production claims.

## MVP B (scale and retrieval experiments)

Only after A/A′ are working and measured:

- SQS-backed durable task dispatch if RDS task polling becomes limiting
- pgvector/OpenSearch/Milvus comparison for retrieval quality and latency
- multimodal PDF/table/chart extraction for cases where text extraction fails
- full filing discovery connectors
- Kubernetes/Helm deployment path

## Rejected: generic agent platform

The project borrows distributed agent platform concepts (orchestrator, workers, registry, artifact storage, memory/search, evaluation, observability), but it must stay grounded in the trading research workload. A generic "agent swarm platform" without a concrete workload is too vague and hard to evaluate.

## Rejected: investment advice product

The platform processes and summarizes financial content. It does not provide personalized financial advice, portfolio allocation, automated trading, price targets, or buy/sell/hold recommendations.
