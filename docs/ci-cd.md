# CI/CD

Enterprise-shaped pipeline for a FastAPI service. AWS demo uses **pipeline-triggered deploy to ECS**; see [ADR 0001](./adr/0001-aws-pipeline-deploy-over-gitops.md) for why not GitOps in v1.

## Workflows

### PR — `ci.yml`

Runs on every pull request:

1. Checkout
2. Install Python dependencies
3. Lint, type check, and test
4. Docker build
5. Trivy image scan — fail on CRITICAL
6. (No deploy)

### AWS demo — `deploy-demo.yml`

Runs on `workflow_dispatch` or version tag (e.g. `v0.1.0`):

1. **OIDC** → assume AWS IAM role (no long-lived `AWS_ACCESS_KEY_ID` in GitHub secrets)
2. Build + test (same as PR)
3. Docker build → tag with **git SHA** and semver tag if applicable
4. Push to **ECR**
5. Update **ECS** task definition / service (new image)
6. Wait for steady state
7. Smoke test `GET /health/ready`

Current scaffold updates the API ECS service first. Worker/scheduler task-definition rollout should be wired once the application runtime roles exist, so the deploy workflow can update all roles from the same image.

## AWS resources (Terraform)

Full VPC layout — see [ADR 0002](./adr/0002-aws-full-vpc-private-rds.md) and [aws-demo-runbook](./aws-demo-runbook.md).

| Resource | Role |
|----------|------|
| VPC | Public + private subnets across 2 AZs |
| NAT gateway | Outbound internet for ECS workers and scheduler tasks (source ingestion / model APIs) |
| VPC endpoints | ECR, Secrets Manager, CloudWatch Logs, S3 — less NAT traffic |
| ALB | Public entry point; health check → `/health/ready` |
| ECS Fargate (API service) | Always-on API in **private subnets** |
| ECS Fargate (worker service) | Background task execution for pipeline and agent workers |
| **EventBridge** | Schedule rule → **ECS RunTask** for one-shot scheduler workflows |
| ECS Fargate (scheduler task) | Same image, `scheduler` role — create due workflow runs and exit |
| S3 | Raw financial documents, extracted artifacts, generated digests, eval exports |
| RDS PostgreSQL | **Private subnet**, not publicly accessible |
| Security groups | ALB → ECS :8080; ECS → RDS :5432 only |
| ECR | Container registry |
| Secrets Manager | DB credentials injected into task definition |
| IAM | Task execution role + task role; GitHub OIDC trust (optional) |
| CloudWatch Logs | stdout from ECS tasks |

Infra lives in `deploy/terraform/`. Runbook: apply → deploy → smoke test → destroy.

## Local Kubernetes (later)

Same image as AWS. A later Helm chart under `deploy/helm/` may target **k3s/kind**:

- Deployment + Service (+ Ingress)
- CronJob scheduled workflow creators
- ConfigMap + Secret
- Liveness/readiness → FastAPI health endpoints

No ArgoCD in v1. CI does not deploy to local k3s automatically.

## GitOps upgrade path (not implemented)

For a multi-environment K8s setup:

```
PR merge → CI build/test/scan → push ECR → update image tag in deploy repo → ArgoCD sync → EKS
```

Keeps the build half identical; only the deploy trigger changes. See ADR 0001.

## FastAPI conventions

- **Python packaging** — `pyproject.toml` with runtime and dev dependency groups
- **Alembic** — schema migrations in repo
- **Runtime roles** — `local`, `api`, `worker`, `scheduler`
- **Health endpoints** — `/health/live`, `/health/ready`
- **Structured JSON logs** — stdout → CloudWatch on ECS

## CV one-liner

GitHub Actions (OIDC) builds and scans Docker images, pushes to ECR, and deploys to ECS Fargate with health-gated rollout; **EventBridge creates scheduled ingestion/digest workflow runs as one-shot ECS tasks**; API and worker services share RDS-backed workflow state, S3 artifacts, and Secrets Manager via IAM task roles; infra in Terraform with documented apply/destroy runbook.

## GitHub repository setup

One-time configuration before the deploy workflow runs.

### 1. Terraform + OIDC

```bash
cd deploy/terraform
# Set github_org in terraform.tfvars, then:
terraform apply
terraform output -raw github_actions_role_arn
terraform output -raw alb_dns_name
```

Ensure a GitHub OIDC provider exists in the AWS account (`token.actions.githubusercontent.com`). Create once per account if missing — see [AWS docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html).

### 2. GitHub secrets and variables

**Environment:** create `aws-demo` (Settings → Environments). Optional: require manual approval before deploy.

| Name | Type | Value |
|------|------|--------|
| `AWS_ROLE_ARN` | Secret | `terraform output -raw github_actions_role_arn` |

| Name | Type | Value |
|------|------|--------|
| `AWS_REGION` | Variable | e.g. `ap-southeast-1` |
| `ECR_REPOSITORY` | Variable | `vibe-trading-research-agent` (match Terraform `project_name`) |
| `ECS_CLUSTER` | Variable | `terraform output -raw ecs_cluster_name` |
| `ECS_SERVICE` | Variable | `terraform output -raw ecs_service_name` |
| `ECS_TASK_FAMILY` | Variable | `vibe-trading-research-agent-demo` (match Terraform task family) |
| `ALB_DNS_NAME` | Variable | `terraform output -raw alb_dns_name` |

Later worker rollout variables:

| Name | Type | Value |
|------|------|--------|
| `ECS_WORKER_SERVICE` | Variable | `terraform output -raw ecs_worker_service_name` |
| `ECS_WORKER_TASK_FAMILY` | Variable | `vibe-trading-research-agent-demo-worker` |

### 3. Workflow files

| File | Trigger | Purpose |
|------|---------|---------|
| `.github/workflows/ci.yml` | PR + push to `main` | Build, test, Docker build, Trivy scan |
| `.github/workflows/deploy-demo.yml` | `workflow_dispatch` or tag `v*` | OIDC → ECR push → ECS deploy → smoke test |

**Prerequisite:** FastAPI app with `pyproject.toml`, an `app` package, and `deploy/docker/Dockerfile`. Workflows will fail until the app scaffold exists.

### 4. First deploy

```bash
# Manual trigger after infra + app are ready:
gh workflow run deploy-demo.yml
# Or tag a release:
git tag v0.1.0 && git push origin v0.1.0
```
