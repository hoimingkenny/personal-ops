resource "aws_ecs_task_definition" "scheduler" {
  family                   = "${var.project_name}-${var.environment}-scheduler"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_scheduler_cpu
  memory                   = var.ecs_scheduler_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "scheduler"
    image     = local.container_image
    essential = true

    command = [
      "python",
      "-m",
      "app.runtime",
      "scheduler"
    ]

    environment = [
      { name = "AWS_REGION", value = var.aws_region },
      { name = "VIBE_TRADING_ARTIFACT_BUCKET", value = aws_s3_bucket.artifacts.bucket }
    ]

    secrets = [{
      name      = "DATABASE_URL"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:database_url::"
    }, {
      name      = "DATABASE_USERNAME"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
    }, {
      name      = "DATABASE_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "scheduler"
      }
    }
  }])
}
