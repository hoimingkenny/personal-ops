output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (ECS, RDS)"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB)"
  value       = aws_subnet.public[*].id
}

output "ecr_repository_url" {
  description = "ECR repository URL for docker push"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "ALB DNS name for smoke tests"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "ecs_worker_service_name" {
  description = "ECS worker service name"
  value       = aws_ecs_service.worker.name
}

output "rds_endpoint" {
  description = "RDS hostname (private — reachable only from ECS)"
  value       = aws_db_instance.main.address
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC (empty until github_org is set)"
  value       = var.github_org != "" ? aws_iam_role.github_actions[0].arn : null
}

output "cloudwatch_log_group" {
  description = "ECS CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "artifact_bucket_name" {
  description = "Private S3 bucket for raw documents, extracted artifacts, digests, and eval exports"
  value       = aws_s3_bucket.artifacts.bucket
}

output "eventbridge_workflow_rule_name" {
  description = "EventBridge rule name for scheduled workflow RunTask"
  value       = aws_cloudwatch_event_rule.workflow_schedule.name
}

output "ecs_scheduler_task_definition_arn" {
  description = "ECS task definition ARN for one-shot scheduler tasks"
  value       = aws_ecs_task_definition.scheduler.arn
}

output "ecs_worker_task_definition_arn" {
  description = "ECS task definition ARN for worker service tasks"
  value       = aws_ecs_task_definition.worker.arn
}
