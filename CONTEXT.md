# Personal Ops OS

A forkable Java/Spring Boot **single-tenant template**: one operator per deployment. Background polling, latest-good snapshot storage, health monitoring, and a **read API** (MVP A). Cloud and CI/CD are first-class — not an afterthought.

Decisions: [`docs/adr/README.md`](docs/adr/README.md). Active build spec (when created): [`.scratch/personal-ops-os/spec.md`](.scratch/personal-ops-os/spec.md).

## Build

**Maven**:
The build tool for this project. CI runs `./mvnw -B verify`; the Docker image copies the Spring Boot repackaged JAR from `target/`.
_Avoid_: Gradle, `./gradlew`.

## Product identity

**Target role**:
Backend / platform engineer (Java + cloud). CV bullets lead with AWS ownership, Terraform, and CI/CD; the aggregation app makes the deploy real.
_Avoid_: pure DevOps-only framing, pure IAM-only framing, AI-agent framing.

**Personal Ops OS**:
The reusable backend template this repo ships. Forkers add connectors; poll-and-store core and deploy scaffold stay unchanged.
_Avoid_: Personal Ops Dashboard, personal assistant, AI agent, hosted multi-tenant platform.

**Single-tenant template**:
One deployment serves one operator (you). Not login/signup SaaS — fork the repo for a second person.
_Avoid_: multi-tenant platform, user spaces, per-user API key vault.

**Cloud demo**:
A short-lived, documented AWS deployment (ECS, ECR, RDS, Secrets Manager, EventBridge) used to prove end-to-end CI/CD. Tear down after capture; do not imply 24/7 production traffic.
_Avoid_: production environment, always-on AWS instance.

**CV MVP (scope A)**:
Cloud-first minimum: Terraform apply → GitHub Actions OIDC deploy to ECS → ALB readiness smoke test → destroy; weather + uptime reference connectors; poll-and-store + EventBridge poller; read **API only** (no UI); Actuator + Flyway; README + architecture diagram + screenshots.
_Avoid_: React UI, dashboard, digest, full connector lineup, LLM, WhatsApp, Redis, Helm, Cloudflare.

**CV MVP A′ (performance follow-on)**:
After A is demoable: Redis cache on read API, k6 load tests, P99 in `docs/benchmarks.md`, optional multi-task ECS. Game Hub–style numbers from **this** project's benchmarks only.
_Avoid_: copying Game Hub TPS/user counts; building a platform to fake concurrency.

**CV MVP B (later)**:
Helm on k3s/kind; optionally one personal connector (e.g. Strava). Only after A's apply → deploy → smoke → destroy works.
_Avoid_: starting B before A demoable.

**Multi-tenant platform**:
Explicitly rejected — register/login, user spaces, per-user API key UI. See [ADR 0003](./docs/adr/0003-product-scope-and-phasing.md).
_Avoid_: hosted SaaS, tenant isolation, credential vault per user.

**Reference connector**:
A working example source (weather, uptime) that demonstrates the connector interface. Personal sources (Binance, Strava) live in the fork, not template defaults.
_Avoid_: built-in source, core connector.

## Backend model

**Source connector**:
Pluggable adapter that fetches and normalises data from one upstream. Implements fetch + health reporting.
_Avoid_: plugin, integration, provider (unless discussing Spring terminology).

**Latest-good snapshot**:
The most recent successful payload for a source, retained in the store when a poll fails. Serve paths never overwrite good data with errors.
_Avoid_: cache entry, last result.

**Poll-and-store**:
Background jobs fetch upstreams and write snapshots to the store. The read API reads only from the store — never from upstreams on the request path. On AWS, EventBridge triggers poller tasks; locally, `@Scheduled` is fine.
_Avoid_: fetch-on-request, live query, pull inside the API service.

**Read API**:
The sole user-facing output in MVP A — JSON snapshots + staleness. No dashboard or digest until later milestones.
_Avoid_: dashboard (MVP A), calling upstreams from controllers.

**Publisher**:
Pluggable output that reads snapshots from the store. **MVP A:** read API only. **Later:** plain-text digest, webhooks.
_Avoid_: channel, notifier; claiming digest ships in MVP A.

**Spring profile (runtime)**:
| Profile | Runs as | Role |
|---------|---------|------|
| `local` | Web + `@Scheduled` polls | Laptop / docker-compose |
| `aws` | Web only | Always-on ECS API service |
| `aws,poller` | No web; poll once and exit | EventBridge ECS RunTask |

## Cloud and delivery

**Pipeline deploy**:
GitHub Actions builds, scans, pushes to ECR, and updates ECS directly. The AWS demo default.
_Avoid_: manual deploy as the primary story; GitOps for AWS (GitOps is K8s scale-up — ADR 0001).

**Private subnet**:
Subnet with no direct internet ingress. ECS tasks and RDS live here; outbound traffic uses NAT or VPC endpoints.
_Avoid_: internal subnet (unless matching AWS console label).

**EventBridge poll**:
EventBridge schedule → one-shot ECS Fargate RunTask with `aws,poller` profile. Replaces in-process `@Scheduled` on AWS.
_Avoid_: CloudWatch Events (legacy name in conversation only — prefer EventBridge in CV/docs).

**Helm chart**:
Kubernetes packaging for local k3s/kind — **MVP B**, not A. Same container image as AWS.
_Avoid_: implying Helm exists before scope B; K8s config bundle.

## Git workflow

**Branch model**:
The repo uses a single long-lived branch (`main`) plus short-lived feature branches per ticket. GitHub Flow, light variant — every change lands on `main` via squash-merge PR.

_Avoid_: develop, release/*, hotfix/*, Git Flow variants.

**Release**:
A versioned tag on `main`, named with semantic versioning (e.g. `v0.1.0`, `v0.1.1`).
_Avoid_: "deploy markers", "release branches".

**Hotfix path**:
A short-lived `fix/*` branch off `main`, merged back via squash PR. Same flow as a feature branch — no separate release line.
