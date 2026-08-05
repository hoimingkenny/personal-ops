# 09 — AWS API, Worker, Scheduler Runtime

## Goal

Run the platform as separate cloud workloads using one container image.

## Scope

- Align FastAPI runtime roles with Terraform: `api`, `worker`, `scheduler`.
- Validate ECS API service, ECS worker service, scheduler task, RDS, S3, EventBridge, Secrets Manager, and CloudWatch.
- Confirm scheduler creates workflow runs and exits.
- Confirm worker service processes tasks.

## Acceptance Criteria

- Terraform plan reflects API service, worker service, scheduler task, artifact bucket, and EventBridge schedule.
- API readiness succeeds through ALB.
- Scheduler task exits successfully after creating due workflow runs.
- Worker logs show task processing.
- Demo stack is destroyed after evidence capture unless explicitly kept alive.

## Out Of Scope

- SQS.
- Step Functions.
- Kubernetes.
