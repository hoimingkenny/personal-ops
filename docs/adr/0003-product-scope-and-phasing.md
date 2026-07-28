# Product scope and phasing

Personal Ops OS is a **single-tenant template** (one operator per deployment): cloud-first MVP **A**, performance follow-on **A′**, Kubernetes depth **B**. Not a hosted multi-tenant platform.

**Target role:** backend / platform engineer — CV leads with AWS ownership (Terraform, ECS, EventBridge, OIDC CI/CD); reliability via poll-and-store; optional Game Hub–style performance bullets from **load tests**, not platform multi-tenancy.

## MVP A (build first)

**In scope:** Terraform (full VPC, private RDS, ECS API service, EventBridge → ECS RunTask pollers, ECR, ALB, Secrets Manager), GitHub Actions OIDC pipeline (Maven, Trivy, ECR push, ECS deploy, readiness smoke test), Spring Boot with weather + uptime reference connectors, poll-and-store (API service + one-shot poller profile), Actuator, Flyway, README + architecture diagram + demo screenshots, documented `terraform destroy`.

**Out of scope:** Helm/k3s, multi-tenant platform (login/spaces/API key UI), React UI, Strava/Binance/Hyperliquid, LLM digest, WhatsApp, Redis, Cloudflare, GitOps/ArgoCD, Lambda, SQS.

**Why cloud-first:** Highest CV ROI is end-to-end AWS + CI/CD; platform or heavy app features delay that signal.

## MVP A′ (performance — after A demoable)

See ADR index — adds read-path benchmarks, not new product surface:

- Redis (or ElastiCache) cache-aside on snapshot read API
- k6 load tests → `docs/benchmarks.md` (RPS, concurrent VUs, P99 cached vs uncached)
- Optional ECS `desired_count > 1` behind ALB
- Postgres indexes; HikariCP noted in README

Honest CV framing: concurrent **load-test clients**, not copied Game Hub user/TPS counts.

## MVP B (later)

Helm on k3s/kind; optionally one personal connector (e.g. Strava). Only after A’s apply → deploy → smoke → destroy works.

## Rejected: multi-tenant platform

Register/login, user spaces, per-user API key UI, and KMS credential vault roughly triple app scope. Performance bullets do **not** require multi-tenancy — A′ suffices.

## Game Hub relationship

Game Hub = production scale (MemoryDB, RabbitMQ, sharding). Personal Ops = cloud ownership + reliability. Same repo can swap CV bullet emphasis by role; do not duplicate Game Hub’s numbers.
