# Architecture Decision Records

Index of locked decisions for Personal Ops OS. Each ADR is one trade-off; grouped by theme for navigation.

## Product scope

| ADR | Decision |
|-----|----------|
| [0003](./0003-product-scope-and-phasing.md) | MVP **A** (cloud-first), **A′** (performance), **B** (Helm); single-tenant; no platform |

## AWS demo (infra + delivery + runtime)

| ADR | Decision |
|-----|----------|
| [0001](./0001-aws-pipeline-deploy-over-gitops.md) | GitHub Actions pipeline → ECS; GitOps as K8s scale-up |
| [0002](./0002-aws-full-vpc-private-rds.md) | Full VPC; RDS in private subnet |
| [0004](./0004-aws-eventbridge-ecs-poll-scheduling.md) | EventBridge → ECS RunTask for polls; API service read-only |

## How to read these

- **0003** = *what* to build and *when*
- **0001–0002–0004** = *how* it runs on AWS (delivery, network, scheduling)

Detailed runbooks: [`docs/ci-cd.md`](../ci-cd.md), [`docs/aws-demo-runbook.md`](../aws-demo-runbook.md).
