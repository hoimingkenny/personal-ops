variable "aws_region" {
  description = "AWS region for the demo stack"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Prefix for resource names"
  type        = string
  default     = "vibe-trading-research-agent"
}

variable "environment" {
  description = "Environment tag (demo only)"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "vibetrading"
}

variable "db_password" {
  description = "RDS master password — set via TF_VAR_db_password or terraform.tfvars (do not commit)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "vibetrading"
}

variable "ecs_task_cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "Fargate task memory (MiB)"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_worker_cpu" {
  description = "Fargate CPU units for worker tasks"
  type        = number
  default     = 512
}

variable "ecs_worker_memory" {
  description = "Fargate memory (MiB) for worker tasks"
  type        = number
  default     = 1024
}

variable "ecs_worker_desired_count" {
  description = "Number of ECS worker service tasks"
  type        = number
  default     = 1
}

variable "ecs_scheduler_cpu" {
  description = "Fargate CPU units for one-shot scheduler tasks"
  type        = number
  default     = 256
}

variable "ecs_scheduler_memory" {
  description = "Fargate memory (MiB) for one-shot scheduler tasks"
  type        = number
  default     = 512
}

variable "workflow_schedule_expression" {
  description = "EventBridge schedule for creating scheduled workflow runs (e.g. rate(1 day))"
  type        = string
  default     = "rate(1 day)"
}

variable "container_image" {
  description = "ECR image URI including tag — update after first push or wire from CI"
  type        = string
  default     = ""
}

variable "github_org" {
  description = "GitHub org/user for OIDC trust (optional until CI is wired)"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repo name for OIDC trust"
  type        = string
  default     = "vibe-trading-research-agent"
}
