# AWS demo infrastructure (Terraform)

Full VPC layout for the Personal Ops OS cloud demo:

- **Public subnets** — ALB
- **Private subnets** — ECS Fargate tasks, RDS PostgreSQL
- **NAT gateway** — outbound internet for pollers (upstream APIs)
- **VPC endpoints** — ECR, Secrets Manager, CloudWatch Logs (reduce NAT traffic)
- **ECR, ECS, RDS, Secrets Manager, IAM (OIDC for GitHub Actions)**

State: local by default. For team use, migrate to S3 backend + DynamoDB lock.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform destroy   # when done
```

See [docs/aws-demo-runbook.md](../../docs/aws-demo-runbook.md).
