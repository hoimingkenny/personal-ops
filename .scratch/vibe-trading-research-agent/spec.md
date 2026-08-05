# Vibe Trading Research Agent

Status: ready-for-agent

## Problem Statement

Retail investors and independent developers who do serious market reading face a noisy research workflow. Useful information is scattered across public financial news, filings, company reports, PDFs, macro sources, and analyst-style commentary. Generic AI tools can summarize text, but they usually do not preserve provenance, verify numeric claims, explain why an item mattered, or make the research process replayable.

The user wants this project to be useful as a trading research workspace while also demonstrating senior backend and AI agent infrastructure skill. The project should not look like a hobby ledger app, a finance chatbot, or another trading bot. It should prove durable async orchestration, typed tool execution, retrieval memory, quality gates, observability, cloud deployment, and performance/cost discipline through a concrete financial research workload.

## Solution

Build Vibe Trading Research Agent as a cloud-native AI agent workflow backend for source-backed trading research. The system ingests governed public financial sources and user-provided report/PDF URLs, stores raw and processed evidence, retrieves relevant chunks/tables/news items, coordinates deterministic pipeline workers and bounded agent workers, verifies citation and numeric claims, and publishes source-backed research artifacts.

The first product surface is digest-first, not chatbot-first. MVP workflows produce daily financial news digests and report briefs. The reusable core is the agent infrastructure beneath the product: workflow orchestration, Skills-Agent separation, bounded ReAct loops, typed tool calling, retrieval/workflow/evaluation memory, quality gates, replay, SSE progress, and AWS runtime roles.

## User Stories

1. As a retail investor, I want curated financial news ingested automatically, so that I can review market signal without manually opening many sources.
2. As a retail investor, I want company report and PDF URLs processed by the system, so that I can turn long documents into structured research briefs.
3. As a retail investor, I want research artifacts to include citations, so that I can verify claims against the original source.
4. As a retail investor, I want numeric claims checked against source evidence, so that I do not trust hallucinated or miscopied numbers.
5. As a retail investor, I want a daily digest of important items, so that I can quickly understand what changed in the market.
6. As a retail investor, I want a report brief for a specific company document, so that I can understand key business, financial, and risk signals.
7. As a retail investor, I want duplicate or low-value items filtered out, so that the digest stays useful instead of noisy.
8. As a retail investor, I want each item classified by type, so that I can separate earnings, macro, research, product, regulatory, and opinion content.
9. As a retail investor, I want items ranked by importance, novelty, source quality, and relevance, so that attention goes to higher-signal material first.
10. As a retail investor, I want the system to keep raw source artifacts, so that research can be audited later.
11. As a retail investor, I want the system to keep extracted chunks and citation anchors, so that generated claims can point to exact evidence.
12. As a retail investor, I want published artifacts to pass quality gates, so that the final output is not raw LLM prose.
13. As a retail investor, I want artifacts that fail quality gates marked for review, so that unsafe summaries do not appear as final research.
14. As a retail investor, I want workflow status visible while a digest is running, so that long-running research does not feel like a black box.
15. As a retail investor, I want progress streamed through server-sent events, so that the interface can show real-time task progress without polling aggressively.
16. As an independent developer, I want a source registry with compliance tiers, so that source ingestion is governed instead of random scraping.
17. As an independent developer, I want source connectors to be pluggable, so that new financial feeds or document sources can be added without rewriting workflows.
18. As an independent developer, I want deterministic ingestion and document workers, so that fetching, parsing, chunking, indexing, and publishing are reliable backend jobs.
19. As an independent developer, I want bounded agent workers only for judgment-heavy tasks, so that LLM usage is controlled and explainable.
20. As an independent developer, I want a classifier/ranker agent, so that the system can decide which candidate items belong in the digest.
21. As an independent developer, I want a brief writer agent, so that selected evidence can be turned into clear research sections.
22. As an independent developer, I want a citation verifier agent, so that unsupported claims are caught before publication.
23. As an independent developer, I want agents to call only allowed tools, so that agent behavior stays constrained.
24. As an independent developer, I want each tool call logged with inputs, outputs, duration, errors, retries, model/prompt version, and cost, so that agent behavior is debuggable.
25. As an independent developer, I want each agent to have runtime limits for steps, tool calls, latency, and cost, so that workflows cannot run unbounded.
26. As an independent developer, I want structured agent outputs, so that downstream quality gates and APIs do not parse fragile prose.
27. As an independent developer, I want retrieval memory over source documents, chunks, tables, metrics, news items, and prior artifacts, so that agents work from grounded evidence.
28. As an independent developer, I want workflow memory for runs, tasks, attempts, events, intermediate artifacts, and failures, so that workflows survive process restarts.
29. As an independent developer, I want evaluation memory for failed checks, corrections, scores, and model comparisons, so that quality improves over time.
30. As an independent developer, I want a replay harness, so that the same workflow can be rerun against stored artifacts for regression checks.
31. As an independent developer, I want eval cases for citations and numeric accuracy, so that model changes can be measured rather than judged by vibes.
32. As an independent developer, I want cost and latency tracked by workflow, agent, model, and tool, so that infrastructure decisions are based on evidence.
33. As an independent developer, I want PostgreSQL full-text retrieval first, so that the MVP stays simple until heavier search infrastructure is justified.
34. As an independent developer, I want search benchmarks and query plans, so that bottlenecks can be identified before adding Redis, OpenSearch, Milvus, or pgvector.
35. As a backend engineer, I want one FastAPI/Python codebase with multiple runtime roles, so that API, worker, and scheduler deployments share one image.
36. As a backend engineer, I want an API runtime role for REST, SSE, workflow status, and artifact reads, so that user-facing traffic is isolated from background work.
37. As a backend engineer, I want a worker runtime role for pipeline and agent task execution, so that long-running work is asynchronous.
38. As a backend engineer, I want a scheduler runtime role triggered by EventBridge, so that scheduled workflows can be created by short-lived tasks.
39. As a backend engineer, I want durable task claiming with database transactions, so that multiple workers can process tasks safely.
40. As a backend engineer, I want retries, timeouts, attempts, and failure states, so that transient errors and permanent failures are explicit.
41. As a backend engineer, I want idempotent ingestion, so that repeated fetches do not duplicate source artifacts or digest items.
42. As a backend engineer, I want artifact storage separated from relational workflow state, so that raw documents and generated outputs are stored efficiently.
43. As a backend engineer, I want database migrations managed through Alembic, so that schema evolution is explicit.
44. As a backend engineer, I want readiness and liveness endpoints, so that local, CI, Docker, and ECS can verify health consistently.
45. As a backend engineer, I want CI to run linting, typing, tests, Docker build, and image scanning, so that regressions are caught before deploy.
46. As a backend engineer, I want GitHub Actions OIDC deployment to AWS, so that the demo avoids long-lived cloud credentials.
47. As a backend engineer, I want ECS services in private subnets and RDS private by default, so that the cloud demo has a realistic security posture.
48. As a backend engineer, I want CloudWatch logs and structured events, so that failures can be diagnosed from the deployed demo.
49. As a backend engineer, I want a documented apply, deploy, smoke test, evidence capture, and destroy path, so that cloud spend stays controlled.
50. As a hiring manager reviewing the project, I want to see source-backed artifacts and evaluation results, so that the project demonstrates engineering depth rather than only prompt design.
51. As a hiring manager reviewing the project, I want to see measured latency, cost, and retrieval quality, so that performance and tradeoff thinking are visible.
52. As a hiring manager reviewing the project, I want the README and evidence docs to be honest about scale, so that the project does not claim fake production experience.

## Implementation Decisions

- The product is named Vibe Trading Research Agent.
- The project is a source-backed trading research workspace, not a trading bot, investment advice product, portfolio tool, or broker integration.
- The MVP is digest-first and report-brief-first. Chat or Q&A may be added later on top of the same evidence store.
- The stack is FastAPI/Python with PostgreSQL, Alembic, Docker, and AWS ECS/RDS/S3/EventBridge for the demo deployment.
- One deployable image supports separate runtime roles: local, API, worker, and scheduler.
- The API role owns REST endpoints, workflow control, workflow status, artifact reads, retrieval/search reads, and SSE progress.
- The worker role owns deterministic pipeline tasks and bounded agent tasks.
- The scheduler role is a short-lived EventBridge-triggered task that creates scheduled workflow runs and exits.
- The source registry governs external inputs. Sources record type, region, sector, compliance tier, license notes, rate limit, freshness expectation, connector type, and enabled state.
- MVP sources are public financial news feeds and user-provided report/PDF URLs. Official-source-first feeds should be preferred where practical.
- Source connectors fetch and normalize external content but do not bypass source terms or hide provenance.
- Raw source artifacts are stored separately from relational metadata. In AWS, object artifacts live in S3.
- PostgreSQL stores workflow state, source metadata, evidence metadata, retrieval records, tool calls, quality gate results, and artifact metadata.
- PostgreSQL full-text search is the first retrieval backend. Redis, OpenSearch, Milvus, pgvector, and similar infrastructure are deferred until benchmarks or explicit experiments justify them.
- Document processing extracts text, sections, chunks, tables when available, metadata, and citation anchors.
- The workflow orchestrator owns workflow runs, tasks, attempts, retries, timeouts, events, replay state, and publish state.
- Deterministic pipeline workers handle ingestion, parsing, chunking, indexing, and publishing.
- Agent workers are reserved for judgment-heavy steps such as classification/ranking, brief writing, citation verification, change detection, and digest composition.
- The agent harness owns agent definitions, skill/tool permissions, bounded ReAct limits, schemas, quality gates, eval cases, replay comparison, publish rules, and budgets.
- Skills are reusable capabilities with explicit input and output schemas.
- Tools are typed backend capabilities invoked by agents or skills. Tool calls are logged with workflow/task context, duration, errors, retries, redacted input/output hashes, model/prompt versions where relevant, token usage, and cost.
- Bounded ReAct loops enforce maximum steps, maximum tool calls, allowed tools, agent timeout, workflow timeout, cost budgets, and structured output schemas.
- Multi-agent collaboration is implemented as orchestrated workflow state and shared evidence, not free-form swarm behavior.
- Retrieval memory is persisted source evidence: documents, chunks, tables, metrics, news items, prior digests, and citation anchors.
- Workflow memory is persisted run state: tasks, attempts, events, tool calls, intermediate artifacts, retries, and failures.
- Evaluation memory is persisted quality history: failed citation checks, numeric mismatches, unsupported claims, human corrections, eval scores, and prompt/model comparisons.
- Quality gates run before publication. MVP gates include schema validity, citation coverage, unsupported-claim checks, numeric-claim verification, latency budget, and cost budget.
- Recommended publish policy: publish only when schema validity passes, citation coverage is at least 95%, unsupported claims have no high-severity failures, and numeric claim verification has no high-severity failures. Otherwise mark the artifact as needing review.
- Artifact publish states include draft, quality-gate-failed, needs-review, approved, and published.
- The first external testing seam is the research workflow API: create a workflow run, observe progress, let workers execute tasks, and assert that the final artifact and quality gate state are correct.
- The second external testing seam is the retrieval/search API: ingest fixtures, query evidence, and assert source-backed citations and ranking behavior from the user's perspective.
- The third external testing seam is the harness/evaluation CLI or service boundary: replay golden cases and assert scores, failures, latency, and cost output.
- CI should run linting, typing, tests, Docker build, and image scanning.
- AWS demo infrastructure uses private ECS tasks, private RDS, ALB health checks, Secrets Manager, CloudWatch logs, S3 artifacts, EventBridge scheduled workflow creation, and GitHub Actions OIDC deploy.
- The project should include README/evidence material after implementation: architecture, local run flow, API examples, sample generated artifacts, eval output, benchmark output, cloud runbook, and teardown proof.

## Testing Decisions

- Tests should verify external behavior and contracts, not implementation details. Good tests assert observable workflow state, API responses, emitted events, persisted artifacts, quality gate outcomes, and eval results.
- The highest-value integration seam is the research workflow API. A test should create a digest or report-brief workflow from fixture sources, run workers, stream or inspect progress, and assert the final published or needs-review artifact.
- API tests should cover liveness, readiness, workflow creation, workflow status, workflow events, artifact reads, source registry operations, and evidence search.
- Worker tests should cover idempotent ingestion, document parsing, chunking, indexing, task claiming, retries, timeouts, and failure states through durable workflow records.
- Retrieval tests should use stable fixture documents and assert citation anchors, metadata filters, Postgres full-text behavior, ranking expectations, and no unsupported source leakage.
- Agent runtime tests should use fake model/tool adapters where possible and assert allowed-tool enforcement, max tool calls, timeout handling, cost budget handling, structured output validation, and deterministic failure states.
- Tool execution tests should assert typed input validation, typed output validation, redacted logging, error logging, retry counts, duration recording, and cost/token recording where applicable.
- Quality gate tests should cover schema validity, citation coverage, unsupported claims, numeric claim matching, tolerance handling, latency budget, and cost budget.
- Evaluation harness tests should run golden cases and assert pass/fail, score, missing citation output, numeric mismatch output, unsupported-claim output, latency, cost, and version metadata.
- Replay tests should rerun stored workflow artifacts against the same and changed agent/prompt/model versions and compare output quality, latency, cost, and failure differences.
- SSE tests should verify that workflow progress events are streamed in order and that terminal states are observable without clients polling aggressively.
- Cloud-adjacent tests should keep AWS mocked or limited to smoke tests. Terraform validation and deployed smoke tests are separate verification steps, not normal unit tests.
- Performance tests should use k6 or an equivalent benchmark harness for search, digest reads, workflow status, and selected workflow paths. Results should be documented before adding caching or heavier retrieval infrastructure.
- Prior art in this repo is currently documentation and scratch ticket based. The first implementation ticket should establish the test harness with ruff, mypy, pytest, FastAPI API tests, and database integration tests.

## Out of Scope

- Stock recommendations, buy/sell/hold advice, price targets, portfolio allocation, personalized financial advice, or investment recommendations.
- Trading bot behavior, automated order placement, broker integrations, portfolio import, or execution systems.
- Paid market data providers, real-time prices, full SEC/HKEX crawler, or broad web crawling in MVP.
- Chatbot-first UX or treating chat transcripts as the main output.
- Free-form autonomous swarm, autonomous agent society, or unbounded agent loops.
- MCP server in MVP.
- Mem0, Milvus, Redis, OpenSearch, pgvector, or Kubernetes/Helm in MVP unless a later benchmark or explicit experiment justifies them.
- Multimodal/VLM extraction and custom model training in MVP.
- Claiming production scale or production trading experience from the demo environment.
- Publishing raw uncited LLM summaries as final artifacts.

## Further Notes

This project should be presented as backend/platform and AI agent infrastructure work. The finance domain gives the system a concrete, useful workload with messy documents, source ambiguity, tables, numbers, retrieval quality, and citation discipline. The CV story should lead with durable workflows, typed tool execution, bounded agents, quality gates, retrieval memory, evaluation, observability, cloud deployment, and measured performance/cost tradeoffs.

MVP A should stay intentionally narrow: build the FastAPI spine, workflow/task state, ingestion/document workers, evidence retrieval, skills/tools registry, bounded agent runtime, digest/report quality gates, research APIs/SSE, AWS API/worker/scheduler runtime, eval harness, and portfolio evidence. MVP B can explore heavier retrieval, queueing, multimodal parsing, full filing discovery, and Kubernetes only after the simple system is working and measured.
