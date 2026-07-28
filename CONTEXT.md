# Personal Ops OS

A forkable Java/Spring Boot backend template for aggregating personal data sources: background polling, latest-good snapshot storage, health monitoring, and pluggable outputs (API, digest). Cloud and CI/CD are first-class — not an afterthought.

## Build

**Maven**:
The build tool for this project. CI runs `./mvnw -B verify`; the Docker image copies the Spring Boot repackaged JAR from `target/`.
_Avoid_: Gradle, `./gradlew`.

## Product identity

**Target role**:
Backend / platform engineer (Java + cloud). CV bullets lead with AWS ownership, Terraform, and CI/CD; the aggregation app makes the deploy real.
_Avoid_: pure DevOps-only framing, pure IAM-only framing, AI-agent framing.

**Personal Ops OS**:
The reusable backend template this repo ships. Users plug in connectors and publishers; the poll-and-store core stays unchanged.
_Avoid_: Personal Ops Dashboard, personal assistant, AI agent.

**Cloud demo**:
A short-lived, documented AWS deployment (ECS, ECR, RDS, Secrets Manager) used to prove end-to-end CI/CD. Tear down after capture; do not imply 24/7 production traffic.
_Avoid_: production environment, always-on AWS instance.

**CV MVP (scope A)**:
Cloud-first minimum for the CV: Terraform apply → GitHub Actions OIDC deploy to ECS → ALB readiness smoke test → destroy; weather + uptime reference connectors; poll-and-store + EventBridge poller; actuator + Flyway; README with architecture diagram and screenshots.
_Avoid_: full connector lineup, LLM digest, WhatsApp, Cloudflare in MVP A.

**CV MVP A′ (performance follow-on)**:
After A is demoable: Redis cache on read API, k6 load tests, P99 in `docs/benchmarks.md`, optional multi-task ECS. Game Hub–style numbers from **this** project's benchmarks only.
_Avoid_: copying Game Hub TPS/user counts; multi-tenant platform as a substitute for load tests.

**Multi-tenant platform**:
Explicitly out of scope — no register/login, user spaces, or per-user API key UI. Single operator per deployment (fork the template).
_Avoid_: hosted SaaS, tenant isolation, credential vault per user — see [ADR 0003](./docs/adr/0003-product-scope-and-phasing.md).

**Reference connector**:
A working example source (e.g. weather, uptime) that demonstrates the connector interface. Forkers copy the pattern; personal sources (Binance, Strava) live in the fork, not the template defaults.
_Avoid_: built-in source, core connector.

## Backend model

**Source connector**:
Pluggable adapter that fetches and normalises data from one upstream. Implements fetch + health reporting.
_Avoid_: plugin, integration, provider (unless discussing Spring terminology).

**Latest-good snapshot**:
The most recent successful payload for a source, retained in the store when a poll fails. Serve paths never overwrite good data with errors.
_Avoid_: cache entry, last result.

**Poll-and-store**:
Background schedulers fetch upstreams on independent cadences and write snapshots to the store. API, dashboard, and digest read only from the store — never from upstreams on the request path.
_Avoid_: fetch-on-request, live query.

**Publisher**:
Pluggable output that reads snapshots from the store (dashboard API, plain-text digest). v1 ships API + digest; WhatsApp and webhooks are extension points only.
_Avoid_: channel, notifier.

## Cloud and delivery

**Pipeline deploy**:
GitHub Actions builds, scans, pushes to ECR, and updates ECS directly. The AWS demo default.
_Avoid_: manual deploy, GitOps (for AWS — GitOps is the K8s scale-up pattern; see ADR 0001).

**Private subnet**:
Subnet with no direct internet ingress. ECS tasks and RDS live here; outbound traffic uses NAT or VPC endpoints.
_Avoid_: internal subnet (unless matching AWS console label).

**EventBridge poll**:
Amazon EventBridge schedule rule that triggers a one-shot ECS Fargate RunTask running the `poller` Spring profile. Replaces in-process `@Scheduled` on AWS; local dev may still use `@Scheduled`.
_Avoid_: CloudWatch Events (legacy name in conversation only — prefer EventBridge in CV/docs).

**Helm chart**:
Kubernetes packaging for local k3s/kind iteration — same container image as AWS, different orchestrator.
_Avoid_: K8s config, yaml bundle.

## Git workflow

**Branch model**:
The repo uses a single long-lived branch (`main`) plus short-lived feature branches per ticket. GitHub Flow, light variant — every change lands on `main` via squash-merge PR.

_Avoid_: develop, release/*, hotfix/*, Git Flow variants.

**Release**:
A versioned tag on `main`, named with semantic versioning (e.g. `v0.1.0`, `v0.1.1`).
_Avoid_: "deploy markers", "release branches".

**Hotfix path**:
A short-lived `fix/*` branch off `main`, merged back via squash PR. Same flow as a feature branch — no separate release line.
