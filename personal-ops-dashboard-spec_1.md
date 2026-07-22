# Personal Ops Dashboard — Build Spec

An always-on backend service that aggregates your real personal-ops data — crypto positions (Hyperliquid, Binance), training (Strava), weather, and service/uptime — into a store, serves a dashboard and a daily digest, and runs on Kubernetes. Designed as a genuinely-used tool *and* a demonstration of backend engineering: resilient multi-source aggregation, failure isolation, caching, secrets handling, and hands-on Kubernetes.

**Guiding principle:** the value is the backend that keeps the dashboard fast and reliable when upstreams are slow, rate-limited, or down — not the UI. Keep a `DECISIONS.md` recording *why* for each choice; that reasoning is what you defend in interviews.

**The decision that defines the design:** decouple fetching from serving. Background pollers fetch each source on its own schedule and write the latest good result to your store; the dashboard, digest, and API read only from the store, never from upstreams. This is what keeps the dashboard fast, keeps you from getting rate-limited or locked out, and turns a "page that calls APIs" into a resilient service.

---

## Sources (final lineup)

| Source | Auth | Risk | Notes |
|---|---|---|---|
| Weather (Open-Meteo / OpenWeatherMap) | API key or none | Trivial | Proving-ground source. Build first. |
| Uptime (your own URL list) | none | Trivial | Richest for backend depth: concurrent checks, timeouts, classification. |
| Binance | **read-only API key** | Low | Official API; create a key scoped read-only (no trade/withdraw). |
| Hyperliquid | API / address query | Low | Official API; query balances/positions. |
| Strava | **OAuth 2.0 + refresh token** | Low | Self-serve single-player mode = your own data. Requires a Strava subscription to create the app. |

Skipped for now: Futu (official but OpenD-gateway complexity), Webull (no official API — unofficial/credential-based, fragile). Add later as connectors if desired.

**Strava specifics to design for:** rate limits are 100 req / 15 min and 1,000 / day (non-upload). Every response carries `X-RateLimit-Limit` / `X-RateLimit-Usage` headers — the connector reads these and throttles before hitting the wall. Strava is *activity*-centric (runs/rides with pace, HR, power) — not all-day wellness (sleep/steps). Polling on a schedule is fine for one user; Strava prefers webhooks for activity data, so note webhook-push as the "more correct" design you'd adopt (good tradeoff to discuss).

**Financial-data safety:** use read-only keys wherever offered (Binance, Hyperliquid). Never store a plaintext trading password. All keys/tokens live in a real secret store (see Secrets, below), never in files or plaintext env.

---

## Build sequence (each stage leaves something working & defensible)

1. **Backend spine** — connector abstraction + poll-and-store + failure isolation, proven with weather + uptime only.
2. **Reliability layer** — timeouts, retry/backoff, rate-limit handling, staleness, concurrent polling.
3. **Real sources** — wire in Binance, Hyperliquid, Strava one at a time using the proven pattern (incl. Strava OAuth token refresh + rate-limit-header throttling).
4. **Serving** — read API + minimal dashboard (reads only from store, shows staleness).
5. **Secrets + observability** — secret store, per-source health, health endpoint, structured logging.
6. **Kubernetes** — run it on local k3s/kind; pollers/digest as CronJobs; Secrets + ConfigMaps; Helm chart; probes wired to health endpoint. (See K8s section.)
7. **Daily digest** — plain templated text first (always works); optional LLM summary pass with plain-text fallback.
8. **Optional polish** — Redis cache tier, uptime history + DB-index story, ArgoCD/GitOps, more sources.

Do not build the frontend first or make it pretty. Do not reach for Kubernetes before the backend works. Both are traps.

---

## Stack

- **Language/Framework:** Java 17+, Spring Boot
- **Scheduling:** Spring `@Scheduled` (in-app) initially; scheduled pollers/digest become K8s CronJobs in stage 6
- **Store:** PostgreSQL (durable + history); Redis optional as fast cache tier
- **Frontend:** minimal — plain React page or server-rendered HTML. Not the point.
- **CI/CD:** GitHub Actions (build, test, Trivy image scan, deploy)
- **Kubernetes:** local **k3s or kind** for learning; Helm for packaging
- **Local dev:** docker-compose (app + Postgres + optional Redis) before moving to k3s

---

## Backend spine (stage 1 — the foundation)

### Connector abstraction

Every source implements one interface:

    interface SourceConnector {
        String sourceId();                 // "weather", "binance", "strava", "uptime:mysite"
        Snapshot fetch();                  // call upstream, return normalised data
        HealthStatus health();             // last success time, OK/DEGRADED/DOWN
    }

- `fetch()` calls the upstream and returns a **normalised** `Snapshot` (a common shape regardless of source).
- Adding a source = writing one connector. Nothing else changes. State this as an explicit design goal — it's your strongest architecture talking point, and it's what makes 5 heterogeneous sources tractable.
- Borrowed from a reference project: each connector self-reports **health**, which later feeds both the dashboard status and the K8s readiness probe.

### Poll-and-store engine

- A scheduler runs each connector's `fetch()` on its own cadence.
- On success: upsert the snapshot with `fetched_at = now`, `status = OK`.
- On failure: log, set `status = ERROR` + `last_error`, **leave the previous good payload intact** (never overwrite good data with an error).
- The API/dashboard/digest read only from the store.

### Data model (minimal)

**source_snapshots**
- `source_id` (string, unique key)
- `payload` (JSON — normalised latest-good data)
- `fetched_at` (timestamp)
- `status` (enum: OK, STALE, ERROR)
- `last_error` (nullable)

(Optional, stage 8) **uptime_history** — append-only check results over time for an uptime %/graph and a DB-index story.

### Failure isolation (the headline reliability feature)

One source failing never affects others or breaks the dashboard. Healthy sources stay fresh; the failed one shows last-known-good marked stale. Story: *"the dashboard stays useful when half its sources are down, because pollers maintain the store independently."*

---

## Reliability layer (stage 2 — where the depth shows)

- **Timeouts** on every upstream call — a hanging API can't stall a poller.
- **Retry with exponential backoff** for transient failures; **back off on 429s**; don't hammer a down service.
- **Per-source scheduling** — uptime ~1 min, crypto balances ~2–5 min, Strava ~15–30 min, weather ~30 min. Be able to justify each cadence and tie it to rate limits.
- **Rate-limit budget tracking** — for Strava, read `X-RateLimit-Usage` from responses and throttle before hitting the limit. (Strong, specific engineering detail.)
- **Staleness as a first-class concept** — system knows each snapshot's age, surfaces it ("balance as of 3 min ago"), marks data past a threshold STALE. Honest > pretending live.
- **Concurrent polling** — poll sources in parallel; uptime checker hits many URLs concurrently with bounded parallelism + per-check timeouts. Clean concurrency story.

---

## Serving (stage 4)

- **Read API** — assembles all current snapshots + freshness from the store. Never calls upstreams. Fast + always-available by construction.
- **Dashboard** — minimal effort; reads only from the API; shows each source's data + staleness. Keep it plain.

---

## Secrets + observability (stage 5)

### Secrets (non-negotiable here)

You hold exchange API keys + a Strava OAuth token — sensitive financial data. Keys live in a **real secret store**, never in files/plaintext env:
- On K8s: **Kubernetes Secrets** mounted into pods (know the caveat: base64, not encrypted-at-rest by default — a real vault is the stronger option, worth stating).
- Read-only API keys wherever offered.
- Extends the secrets-management lesson from your CLSA work into the K8s idiom.

### Strava OAuth token lifecycle

Strava tokens expire and use refresh tokens. The connector must refresh transparently. Small but real — a good "how do you handle third-party auth" answer.

### Observability

- Each connector self-reports health.
- A **health endpoint** exposes per-source status + last-success time (also feeds K8s readiness probe).
- Structured logging with enough context to debug a failing source.
- (Optional) alert when a source is down past a threshold.

---

## Kubernetes (stage 6 — the operating story)

**Do this on local k3s or kind. Do NOT reach for EKS** — the control-plane cost and setup time will eat the project. Local k3s gives you every concept below for free. Keep the *always-on real instance* simple (VPS-k3s or ECS — decide separately); split learning from hosting to stay cheap.

Your architecture maps onto K8s unusually cleanly:

- **API/dashboard** → Deployment + Service + Ingress. Learn **liveness/readiness probes** (wire readiness to your health endpoint), **resource requests/limits**, rolling deploy + rollback.
- **Scheduled pollers + daily digest** → **CronJobs** (the standout mapping). A Strava poll every 15 min and the daily digest are textbook CronJobs — teaches Jobs/CronJobs and "scheduled work as a cluster resource."
- **Secrets** → Kubernetes Secrets (exchange keys, Strava token).
- **Config** (cadences, source URLs, thresholds) → ConfigMaps (config separated from image).
- **Database** → managed/out-of-cluster (learn "stateful stays outside") or in-cluster StatefulSet + PersistentVolume if you want that experience.
- **Packaging** → **Helm chart** templating Deployment/Service/Ingress/ConfigMap/Secret/CronJob. High-return, commonly asked about.
- **(Optional) GitOps** → ArgoCD driving declarative deploys. Most current story, most extra scope — only if core is done.

**Why this fixes your CV gap:** you have CKAD + OpenShift-deploy already; the gap is *recent hands-on*. Running this on k3s with CronJob pollers, Secrets, ConfigMaps, a Helm chart, and probes wired to your health endpoint converts "certified, deployed once" into "certified and actively building/running services on K8s with the core primitives." That's enough — everything beyond is upside.

---

## Daily digest (stage 7)

- Once-a-day summary composed from stored snapshots: portfolio position, recent training, service health, weather.
- **Build plain templated text first** — always works, no dependencies (the reference project's "always produce output" discipline).
- **Optional LLM pass** on top (GPT-4o-mini or your local LLM) to compose a nicer summary, **with a plain-text fallback if the LLM is unreachable**. Low-risk place for a small AI touch tied to your interests — without turning this into an agent.
- As a CronJob in K8s.

---

## CI/CD (build alongside)

GitHub Actions: build → test → Trivy image scan → push → deploy. Reinforces/modernises the CI/CD you own at CLSA, in a context you fully control.

---

## What this becomes on the CV

> **Personal Ops Dashboard** — Built an always-on aggregation service (Java/Spring Boot, PostgreSQL) that polls multiple external sources (crypto exchanges, Strava, weather, uptime) on independent schedules and serves a unified dashboard and daily digest, with a pluggable connector abstraction, per-source failure isolation, staleness handling, and rate-limit-aware polling so the dashboard stays fast and available when upstreams fail. Deployed on Kubernetes (k3s) with pollers as CronJobs, secrets managed via K8s Secrets, packaged with Helm, through a GitHub Actions pipeline with image scanning.

Framed by engineering (resilient aggregation, failure isolation, concurrency, K8s), not the UI. Hits several target gaps — backend design, reliability, hands-on Kubernetes, CI/CD — in one genuinely-used project.

---

## Interview questions this must let you answer

- How do you keep the dashboard fast/reliable when it depends on flaky third-party APIs? → decoupled poll-and-store.
- What happens when one source goes down? → failure isolation, last-known-good, staleness.
- How do you handle upstream timeouts, rate limits, retries? → timeouts, backoff, per-source cadence, Strava header-budget throttling.
- Why poll-and-store rather than fetch-on-request? → speed, availability, rate-limit protection.
- How would you add a new source? → new connector, nothing else changes.
- How is third-party auth handled? → Strava OAuth refresh, read-only keys.
- How is it deployed/operated? → k3s, CronJob pollers, Secrets, ConfigMaps, Helm, probes wired to health.
- Why CronJobs for the pollers? → scheduled work as a cluster resource; isolation, retries, scheduling handled by K8s.
- (If asked on secrets) K8s Secrets vs a vault? → base64 not encrypted-at-rest; vault is stronger — you know the distinction.

---

## DECISIONS.md — keep as you go

Capture, per choice: what you chose, alternatives, why, what you'd do at larger scale. Examples: fetch-on-request vs poll-and-store; per-source cadences; timeout/retry/backoff policy; last-known-good on failure; polling vs Strava webhooks; in-app scheduler vs K8s CronJobs; K8s Secrets vs vault; DB in-cluster vs managed; ECS vs k3s for the always-on instance.

---

## Deployment — final decision

Three environments, each chosen for its purpose in the cheapest sensible way:

- **Local k3s / kind** — Kubernetes learning and iteration during the build (free). CronJob pollers, Secrets, ConfigMaps, Helm, probes wired to the health endpoint.
- **AWS — short-lived demonstration deploy (for the CV credential, not 24/7):** deploy the containerised Java/Spring service to **ECS**, image in **ECR**, secrets from **Secrets Manager** (via the task's IAM role), database on **RDS** (small instance). Keep it minimal (single task, same-VPC RDS). Stand it up, wire the GitHub Actions pipeline to it, confirm end-to-end, **capture screenshots + notes** (running task, pipeline deploy, task pulling from Secrets Manager), then tear it down. A few days of run time = a few dollars. CV line: "deployed to AWS (ECS, ECR, Secrets Manager, RDS) via a GitHub Actions pipeline" — honest for a short-lived deploy; don't imply 24/7 production traffic.
- **Cloudflare — the always-on personal instance (near-free, serverless/edge):** see below.

### Cloudflare reimplementation (SECOND build — do only after the Java backend is finished)

The always-on personal version runs on Cloudflare's free-tier-friendly serverless platform. This is a **separate implementation in TypeScript**, not a redeploy of the Java app — a fresh build sharing the same concept.

Primitive mapping:
- **Pollers → Cron Triggers** (scheduled Workers). Maps cleanly to the poller model.
- **Service/API → Workers** (request-triggered, stateless — no always-on process; the "background service" concept changes).
- **Store → D1** (SQLite-based) or **KV** for simple snapshots. Not Postgres.
- **Language → TypeScript/JS/WASM**, not JVM.

Value: gives you a **serverless/edge story** alongside the traditional-backend story — the same problem solved two ways, which is a strong architectural-tradeoff talking point ("why scheduling and state differ on serverless, and when I'd choose each"). Cost: likely near-zero on Cloudflare's free tier at single-user scale (confirm current limits when building).

**Scoping discipline:** build the Java/Spring backend first and completely — it's the primary CV artifact and the more valuable one for backend roles. Do Cloudflare only as the follow-on second build once the primary is solid. Do NOT start both in parallel — two half-finished projects is the failure mode. Two done well beats three half-done.
