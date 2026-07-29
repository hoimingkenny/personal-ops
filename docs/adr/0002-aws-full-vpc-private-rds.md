# AWS demo: full VPC with private RDS

Terraform provisions a **full VPC**: public subnets (ALB), private subnets (ECS Fargate, RDS). RDS is **not publicly accessible**; only the ECS security group reaches port 5432.

**Why:** Production-shaped networking — interviewers ask how the app reaches the DB and why RDS isn’t on the internet. Shortcut layouts weaken the cloud credential.

**Cost:** NAT gateway while stack runs; VPC endpoints (ECR, Secrets Manager, Logs) reduce NAT traffic; **short-lived demo** — `terraform destroy` after capture.

```
Internet → ALB (public) → ECS (private) → RDS (private)
                              ↓ NAT + VPC endpoints (pollers reach upstream APIs)
```

**Interview line:** *"RDS has no public IP; only ECS can connect. ALB is the sole public entry."*

## Consequences

- `vpc.tf`, `security_groups.tf`, `vpc_endpoints.tf`, `rds.tf`, `ecs.tf`, `alb.tf`
- ECS tasks: `assign_public_ip = false`
