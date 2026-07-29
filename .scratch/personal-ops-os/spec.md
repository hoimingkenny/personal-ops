# Personal Ops OS — Build Spec (MVP A)

**Status:** ready-for-agent

**Feature slug:** `personal-ops-os`

**Authoritative decisions:** [`docs/adr/README.md`](../../docs/adr/README.md), [`CONTEXT.md`](../../CONTEXT.md)

---

## Problem Statement

You need a **credible backend/platform portfolio piece** that proves end-to-end **AWS ownership** (Terraform, ECS, EventBridge, RDS, Secrets Manager, OIDC CI/CD) — not just Spring Boot CRUD or cert-only cloud knowledge. You also want a **genuinely useful single-tenant tool** that aggregates personal data (weather, uptime first) from flaky upstream APIs without slow or fragile fetch-on-request reads.

Your CV already shows Java, Spring, IAM, OpenShift, and messaging at scale (Game Hub). The gap is **infra you designed and deployed yourself**, plus a clear **reliability story** (poll-and-store, failure isolation, staleness).

## Solution

**Personal Ops OS** is a forkable Java/Spring Boot **single-tenant template**: background jobs **pull** upstream data into PostgreSQL as **latest-good snapshots**; a **read API** serves only from the store. On AWS, **EventBridge** triggers one-shot **ECS RunTask** poller jobs; an always-on **ECS service** serves the API. **Terraform** provisions a production-shaped VPC; **GitHub Actions** (OIDC) builds, scans, and deploys to ECR/ECS.

MVP A optimises for **cloud + reliability**. MVP A′ (later) adds Redis + k6 benchmarks for performance CV bullets. MVP B (later) adds Helm/k3s and optional personal connectors (Strava, etc.).

## User Stories

### Operator (single tenant)

1. As an operator, I want to run the app locally with Postgres via docker-compose, so that I can develop without AWS cost.
2. As an operator, I want weather data polled automatically, so that I see current conditions without opening a weather site.
3. As an operator, I want configured URLs checked for uptime on a schedule, so that I know if my services are reachable.
4. As an operator, I want to read all source snapshots via a JSON API, so that I can build any UI or script on top later.
5. As an operator, I want each snapshot to show age and staleness, so that I trust how fresh the data is.
6. As an operator, I want a failed upstream to not wipe previous good data, so that the API stays useful when one source is down.
7. As an operator, I want one source failing to not block others, so that partial outages are isolated.
8. As an operator, I want health and readiness endpoints, so that load balancers and Kubernetes (later) can probe the service.
9. As an operator, I want per-source health reflected in actuator output, so that I can debug a bad connector quickly.
10. As an operator, I want to add a new data source by implementing one connector interface, so that the template stays extensible without core changes.

### Forker (template adopter)

11. As a forker, I want a clear connector interface and two reference implementations, so that I can copy the pattern for Binance or Strava in my fork.
12. As a forker, I want domain terms documented in CONTEXT.md, so that agents and humans share vocabulary.
13. As a forker, I want ADRs explaining AWS and scope choices, so that I understand why the template is shaped this way.

### Cloud / CV demonstrator

14. As a demonstrator, I want `terraform apply` to stand up VPC, private RDS, ECS, ALB, ECR, Secrets Manager, and EventBridge, so that I can discuss production-shaped networking in interviews.
15. As a demonstrator, I want GitHub Actions to deploy via OIDC (no static AWS keys), so that I can describe modern CI/CD auth.
16. As a demonstrator, I want Trivy to gate images on CRITICAL vulnerabilities, so that the pipeline shows supply-chain awareness.
17. As a demonstrator, I want a documented tear-down runbook, so that I can honestly describe a short-lived demo and its cost.
18. As a demonstrator, I want screenshots of ECS, EventBridge poller tasks, ECR, and pipeline runs, so that CV claims are verifiable.
19. As a demonstrator, I want the same container image to run as API service and one-shot poller, so that I can explain profile-based task definitions.
20. As a demonstrator, I want to capture at least one incident note while building, so that I can answer “what broke and how you fixed it.”

### Local development

21. As a developer, I want `@Scheduled` polling under the `local` profile, so that I do not need EventBridge on my laptop.
22. As a developer, I want Flyway migrations for the snapshot schema, so that schema changes are versioned.
23. As a developer, I want `./mvnw -B verify` to run unit and integration tests, so that CI matches local workflow.

### Explicit non-goals (MVP A)

24. As an operator, I do **not** need a web dashboard in MVP A — the read API is enough.
25. As an operator, I do **not** need login or multi-user spaces — I fork the repo for a second person.
26. As an operator, I do **not** need LLM digest or WhatsApp in MVP A.

## Implementation Decisions

### Architectural shape

- **Poll-and-store** is the core pattern: fetch paths write snapshots; serve paths never call upstreams.
- **Single-tenant**: no `user_id` column; one operator per deployment.
- **Decouple pull from serve on AWS**: API ECS service (`aws` profile) vs EventBridge-triggered poller RunTask (`aws,poller` profile). Same JAR, same ECR image.
- **Local profile** uses in-process `@Scheduled` polling; AWS uses EventBridge only for schedules.
- **No message queue** in MVP A: Postgres is the handoff between poll and serve.
- **No Lambda** in MVP A: Spring Boot + Fargate is the compute model.

### Modules (logical)

| Module | Responsibility |
|--------|----------------|
| **SourceConnector** | Upstream fetch + health for one source |
| **ConnectorRegistry** | Enabled connectors from configuration |
| **PollEngine** | Invoke connectors (parallel), apply failure-isolation rules, persist results |
| **SnapshotStore** | Upsert/read latest-good snapshots + staleness |
| **PollRunner** | Entry for one poll cycle (used by scheduler locally and ApplicationRunner on `aws,poller`) |
| **SnapshotReadService** | Assemble read API response from store |
| **Health aggregation** | Actuator contributors from store + connector health |

### SourceConnector interface

```
sourceId(): String
fetch(): Snapshot          // normalised payload
health(): HealthStatus     // OK | DEGRADED | DOWN, last success, optional message
```

Reference connectors in MVP A: **weather** (Open-Meteo, no auth), **uptime** (configurable URL list, concurrent checks with timeouts).

### Snapshot model

```
source_snapshots
  source_id       VARCHAR PRIMARY KEY
  payload         JSONB NOT NULL
  fetched_at      TIMESTAMPTZ NOT NULL
  status          VARCHAR NOT NULL   -- OK, STALE, ERROR
  last_error      TEXT NULL
```

**Latest-good rule:** on fetch failure, set `status = ERROR` and `last_error`; do **not** overwrite `payload` if a previous good payload exists.

**Staleness:** computed on read — if `now - fetched_at` exceeds configurable threshold per source, expose as STALE in API even when last poll succeeded.

### Reliability (PollEngine)

- Per-upstream **timeouts** (e.g. connect/read limits via HTTP client config).
- **Retry with exponential backoff** for transient failures; respect **429** with backoff.
- **Concurrent polling** across sources; uptime checks URLs with bounded parallelism.
- PollEngine catches per-connector exceptions; one failure does not abort the batch.

### Spring profiles

| Profile | Web | Polling | Lifecycle |
|---------|-----|---------|-----------|
| `local` | Yes | `@Scheduled` | Long-running |
| `aws` | Yes | No | Long-running ECS service |
| `aws,poller` | No (`web-application-type=none`) | Once on startup via ApplicationRunner | Exit 0 after poll cycle |

Poller profile runs PollRunner once, then shuts down the context.

### Read API (MVP A sole publisher)

- `GET /api/snapshots` — all sources with payload, `fetched_at`, `status`, staleness indicator, optional `last_error`.
- `GET /api/snapshots/{sourceId}` — single source.
- Controllers delegate to SnapshotReadService only — **no connector injection in web layer**.

### Actuator

- **Liveness:** JVM/process up.
- **Readiness:** Postgres reachable; optional gate if all configured sources are ERROR beyond threshold (document chosen policy in README).
- **Health detail:** per-source status from SnapshotStore / last poll metadata.

### Secrets and configuration

- **Local:** env vars / application-local.yml for Postgres; uptime URL list in config.
- **AWS:** JDBC URL and credentials from Secrets Manager via ECS task secrets (Terraform already injects). No exchange API keys in MVP A reference connectors.
- Infra DB secret is separate from future per-connector secrets (out of scope).

### Build and packaging

- **Maven** wrapper; Java 21; Spring Boot 3.x.
- **Docker:** layered JAR; image used for ECS service and poller task.
- **docker-compose:** app + Postgres for local dev (add when app exists).

### Cloud (already scaffolded — activate after app runs locally)

- Terraform: full VPC, private RDS, ALB, ECS API service, EventBridge → poller task def, ECR, Secrets Manager, IAM (execution, task, EventBridge, GitHub OIDC).
- CI: `ci.yml` (verify + Trivy); `deploy-demo.yml` (OIDC → ECR → ECS).
- Demo is **short-lived**; capture evidence then `terraform destroy`.

### Build order (implementation sequence)

1. Maven spine + actuator + Flyway + docker-compose Postgres — `./mvnw verify` green.
2. SnapshotStore + SourceConnector + PollEngine with fake/in-memory connector — tests at PollEngine seam.
3. Weather + uptime reference connectors.
4. Read API + staleness.
5. `local` scheduled polling end-to-end.
6. `aws` / `aws,poller` profiles + poller exit behaviour.
7. Docker image builds locally.
8. Terraform apply + manual image push + smoke test readiness.
9. Wire GitHub Actions deploy-demo; EventBridge poller verification.
10. README architecture diagram, runbook evidence, optional `docs/incidents.md` entry.

### Primary test seam (proposed)

**Test at the PollEngine boundary** with fake SourceConnector implementations and a real Postgres (Testcontainers) SnapshotStore:

- Poll success writes OK snapshot.
- Poll failure preserves latest-good payload.
- One connector throwing does not prevent others from persisting.
- Read API integration tests assert serve path never invokes connectors (wire mock connectors only into PollEngine tests, not web tests).

HTTP tests for read API use MockMvc + Testcontainers Postgres with pre-seeded snapshots.

*This seam was chosen as the highest behavioural surface: poll-and-store + failure isolation in one place.*

## Testing Decisions

### What makes a good test

- Assert **observable behaviour**: snapshot contents, status, staleness flags, HTTP response bodies, actuator status codes.
- Do **not** assert internal call order, private methods, or scheduler internals.
- Prefer **Testcontainers PostgreSQL** for integration tests that touch SnapshotStore.
- Use **fake connectors** that return deterministic snapshots or throw controlled exceptions.

### Modules under test

| Layer | Test type |
|-------|-----------|
| PollEngine + SnapshotStore | Integration (Testcontainers) with fake connectors |
| Reference connectors | Unit/integration with WireMock or similar for HTTP upstreams |
| Read API | MockMvc integration with seeded DB |
| Poller profile | Spring Boot test: context starts, ApplicationRunner completes, process would exit (use `@SpringBootTest` with test profile) |
| Actuator readiness | MockMvc `/actuator/health/readiness` with/without DB |

### Prior art

Greenfield — establish patterns in first tickets. Follow Spring Boot + Testcontainers conventions; no existing test suite in repo.

### CI

- `./mvnw -B verify` on every PR.
- Docker build + Trivy after tests pass (workflows already scaffolded).

## Out of Scope

### MVP A (do not build in initial spec)

- Multi-tenant platform (register/login, user spaces, per-user API keys)
- React or server-rendered dashboard UI
- Daily digest, LLM summarisation, WhatsApp
- Binance, Hyperliquid, Strava, crypto connectors
- Redis / ElastiCache (MVP **A′**)
- k6 benchmarks (MVP **A′**)
- Helm / k3s / CronJobs (MVP **B**)
- GitOps / ArgoCD on AWS
- Lambda, SQS, Kafka
- Cloudflare second implementation
- EKS
- 24/7 production pretense on CV — demo is short-lived and documented

### Infrastructure not requiring app changes

- Terraform and workflows exist as scaffold; full `terraform apply` + OIDC deploy validation is in scope for MVP A **after** the application artifact exists.

## Further Notes

### CV framing (two bullet variants, same repo)

**Cloud/platform (lead for target role):** Terraform VPC + private RDS; ECS Fargate API + EventBridge poller tasks; GitHub Actions OIDC → ECR → health-gated ECS deploy; poll-and-store with failure isolation.

**Performance (after A′):** Redis cache-aside on read API; k6 at N RPS / concurrent VUs; P99 cached vs uncached — numbers from `docs/benchmarks.md` only.

### Game Hub relationship

Game Hub demonstrates production scale (MemoryDB, RabbitMQ, sharding). Personal Ops demonstrates **owned cloud deploy + reliability architecture**. Do not copy Game Hub throughput figures.

### Agent implementation discipline

- One ticket per session; see `/to-tickets` output (to be generated from this spec).
- Do not implement platform, dashboard, or A′/B scope unless a ticket explicitly says so.
- Commit on feature branches; squash merge to `main`.

### Open items for `/to-tickets`

- Readiness policy when all sources ERROR (fail readiness vs degraded-but-up).
- Default staleness thresholds per source (weather 60m, uptime 5m — tune in config).
- Uptime URL list configuration shape (YAML list under `personal-ops.uptime.urls`).

## References

- [ADR 0003 — Product scope and phasing](../../docs/adr/0003-product-scope-and-phasing.md)
- [ADR 0004 — EventBridge poll scheduling](../../docs/adr/0004-aws-eventbridge-ecs-poll-scheduling.md)
- [AWS demo runbook](../../docs/aws-demo-runbook.md)
- [CI/CD doc](../../docs/ci-cd.md)
