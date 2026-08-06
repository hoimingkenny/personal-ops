# 12 — AWS API Worker Scheduler Demo

**What to build:** A short-lived AWS demo where the same image runs as API, worker, and scheduler roles. The deployment proves cloud ownership through ECS, RDS, S3 artifacts, EventBridge scheduled workflow creation, Secrets Manager, CloudWatch logs, and health-gated deployment.

**Blocked by:** 10 — Research API And SSE Progress.

**Status:** ready-for-agent

- [ ] The API service runs on ECS and passes liveness/readiness health checks behind the load balancer.
- [ ] The worker service can process workflow tasks using RDS-backed workflow state.
- [ ] The EventBridge-triggered scheduler task can create scheduled workflow runs and exit.
- [ ] Raw documents, extracted artifacts, generated digests, or eval exports can be stored in the artifact bucket.
- [ ] Secrets and database connection settings are injected through the cloud runtime configuration.
- [ ] CloudWatch logs provide enough evidence to diagnose API, worker, and scheduler behavior.
- [ ] The runbook supports apply, deploy, smoke test, evidence capture, and destroy.
