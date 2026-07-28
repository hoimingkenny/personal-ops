# Full VPC with private RDS for the AWS demo

The AWS demo Terraform stack provisions a **full VPC**: public subnets for the ALB, private subnets for ECS Fargate tasks and RDS PostgreSQL. RDS is **not publicly accessible**; only the ECS task security group may connect on port 5432.

**Why:** This matches how enterprise Spring Boot services are deployed on AWS. Interviewers routinely ask how the app reaches the database and why RDS is not on the internet. A shortcut layout (public RDS, open security groups) works for a hack but signals unfamiliarity with production networking. The extra Terraform is the cloud credential.

**Cost control:** NAT gateway is the main ongoing cost while the stack runs. VPC interface endpoints for ECR, Secrets Manager, and CloudWatch Logs reduce NAT traffic. The demo is **short-lived** — `terraform destroy` after capture (see `docs/aws-demo-runbook.md`).

## Considered options

| Option | Rejected because |
|--------|------------------|
| RDS in public subnet | Does not demonstrate production network isolation |
| `0.0.0.0/0` on RDS security group | Security anti-pattern; weak interview story |
| Default VPC only | No explicit subnet/SG design to discuss |
| **Full VPC + private RDS** (chosen) | — |

## Layout

```
Internet → ALB (public subnets) → ECS tasks (private subnets) → RDS (private subnets)
                                      ↓
                              NAT gateway (outbound to upstream APIs)
                              VPC endpoints (ECR, Secrets Manager, Logs — less NAT traffic)
```

## Consequences

- `deploy/terraform/` includes `vpc.tf`, `security_groups.tf`, `vpc_endpoints.tf`, `rds.tf`, `ecs.tf`, `alb.tf`.
- ECS tasks use `assign_public_ip = false`.
- App pollers need NAT (or separate egress design) to reach external APIs — document in runbook.
- Interview line: *"RDS has no public IP; only the ECS security group can reach it. ALB is the sole public entry point."*
