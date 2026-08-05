# AWS demo runbook

Short-lived AWS deployment to prove cloud + CI/CD. **Not** a 24/7 production environment. Tear down after screenshots and smoke tests.

See also: [CI/CD](./ci-cd.md), [ADR index](./adr/README.md), [ADR 0001](./adr/0001-aws-pipeline-deploy-over-gitops.md), [ADR 0002](./adr/0002-aws-full-vpc-private-rds.md).

## Prerequisites

- AWS account with admin or scoped permissions for VPC, ECS, RDS, ECR, Secrets Manager, IAM
- Terraform >= 1.5
- AWS CLI configured
- Docker (for local image build until CI is wired)

## 1. Provision infrastructure

```bash
cd deploy/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set db_password via env or tfvars (never commit)

terraform init
terraform plan
terraform apply
```

Note outputs: `ecr_repository_url`, `alb_dns_name`, `ecs_cluster_name`, `ecs_service_name`.

## 2. Deploy the application

**Option A — GitHub Actions (target state):** Run `deploy-demo` workflow with OIDC role from Terraform output.

**Option B — Manual (bootstrap):**

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"
docker build -t vibe-trading-research-agent:demo ../../  # once Dockerfile exists
docker tag vibe-trading-research-agent:demo "$ECR_URL:demo"
docker push "$ECR_URL:demo"
aws ecs update-service --cluster "$(terraform output -raw ecs_cluster_name)" \
  --service "$(terraform output -raw ecs_service_name)" --force-new-deployment
```

## 3. Smoke test

```bash
curl -sf "http://$(terraform output -raw alb_dns_name)/health/ready"
```

Expect `200` when the app and RDS are healthy.

## 4. Capture evidence

Save under `docs/aws-demo/` (gitignored if containing account IDs):

- Terraform plan/apply summary
- ECR image with SHA tag
- ECS running task (API service)
- EventBridge rule + successful scheduler RunTask in ECS **Stopped** tasks
- ECS worker service processing workflow tasks
- S3 artifact paths for raw documents, extracted content, generated digest, or eval output
- RDS in private subnet (console screenshot)
- Secrets Manager secret reference in task definition
- Successful GitHub Actions run
- CloudWatch log line from startup

## 5. Tear down

```bash
cd deploy/terraform
terraform destroy
```

Verify RDS and NAT gateway are gone — these are the main cost drivers if left running.

## Approximate cost (2–3 day demo)

| Resource | Rough cost |
|----------|------------|
| NAT gateway | ~$1–2/day + data |
| RDS db.t4g.micro | ~$0.50/day |
| ECS Fargate (minimal task) | ~$0.50/day |
| ALB | ~$0.50/day |

**Total:** a few dollars for a weekend demo if destroyed promptly.

## Troubleshooting

| Symptom | Check |
|---------|--------|
| ECS task won't start | CloudWatch logs; task execution role ECR pull; image tag exists |
| Can't pull ECR image | VPC endpoints for `ecr.api`, `ecr.dkr`, S3 gateway endpoint |
| App can't reach RDS | ECS task SG → RDS SG on 5432; JDBC URL from Secrets Manager |
| App can't reach upstream APIs | NAT gateway route on private subnet route table |
| Readiness probe fails | RDS reachable; Alembic migrated; dependency health checks |
| EventBridge not starting scheduler runs | Rule enabled; IAM `eventbridge_ecs` role; scheduler task definition; check ECS **Stopped** tasks and CloudWatch log stream prefix `scheduler` |
