# Senior skill map

Vibe Trading Research Agent should read as senior backend/platform/AI-agent infrastructure work, not as a stock picker or trading bot. The trading research workload is intentionally concrete; the senior signal comes from workflow durability, tool control, retrieval quality, evaluation, observability, cloud deployment, and measured performance/cost tradeoffs.

## Target signal

For backend/platform/AI agent roles, the repo should prove that the author can:

- design durable async workflows instead of blocking request/response chains
- separate deterministic pipeline workers from bounded agent workers
- expose typed tool calls with permissions, logs, cost, and errors
- build retrieval memory over source-backed documents, chunks, tables, and news
- verify AI output with citation and numeric accuracy quality gates
- make agent runs observable, replayable, and debuggable
- use AWS primitives intentionally: ECS API/worker/scheduler, RDS, S3, EventBridge, Secrets Manager, CloudWatch
- measure latency, throughput, retrieval quality, eval pass rate, and AI cost before adding heavier infrastructure

## Evidence by skill

| Senior skill | Repo evidence to produce |
|--------------|--------------------------|
| Agent orchestration | Workflow runs, task graph, task attempts, retries, timeouts, replay, SSE progress. |
| Skills-Agent architecture | Agent definitions with allowed skills/tools, structured input/output, prompt/model versions, and capability boundaries. |
| Bounded ReAct loops | Max tool calls, timeout, cost budget, allowed tools, and structured final artifact. |
| Tool execution layer | Logged typed tool calls for document search, chunk retrieval, table extraction, metric extraction, citation verification, and digest writing. |
| Retrieval/RAG | Postgres FTS first; chunking, metadata filters, citation anchors, retrieval evals; later vector/OpenSearch/Milvus comparison only if justified. |
| Memory model | Workflow memory, retrieval memory, and evaluation memory as explicit persisted stores. |
| Evaluation harness | Golden cases for citation coverage, numeric accuracy, unsupported claims, schema validity, latency, and cost. |
| Cloud operations | Terraform VPC/private RDS/ECS/S3/EventBridge/Secrets Manager/CloudWatch/ECR/ALB, OIDC CI/CD, Trivy, smoke tests, teardown. |
| Performance/cost | k6 benchmarks, query plans, cache experiments, token/cost per digest, and before/after tuning notes. |

## Portfolio framing

Lead with the infrastructure, not the finance domain:

> Built a cloud-native AI agent workflow backend for source-backed trading research, with durable async orchestration, Skills-Agent separation, bounded ReAct loops, typed tool execution, retrieval/workflow/evaluation memory, citation/numeric quality gates, SSE progress streaming, and AWS ECS/RDS/S3/EventBridge deployment via Terraform and OIDC CI/CD.

After benchmarks and evals exist, add measured numbers only from this repo:

> Benchmarked research/search APIs and agent workflows with k6 and eval harnesses, documenting P95/P99 latency, citation coverage, numeric accuracy, token cost per artifact, and the tradeoff before adding Redis or heavier search infrastructure.

## Do not fake seniority

- Do not claim production scale from a demo stack.
- Do not claim investment advice, trading automation, or price prediction.
- Do not add Redis, Milvus, Mem0, OpenSearch, Kubernetes, or multimodal models just to name-drop them.
- Do not publish uncited LLM summaries as the main artifact.
