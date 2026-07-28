
resource "aws_ecs_task_definition" "poller" {
  family                   = "${var.project_name}-${var.environment}-poller"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_poller_cpu
  memory                   = var.ecs_poller_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "poller"
    image     = local.container_image
    essential = true

    command = [
      "java",
      "-jar",
      "app.jar",
      "--spring.profiles.active=aws,poller"
    ]

    environment = [
      { name = "AWS_REGION", value = var.aws_region }
    ]

    secrets = [{
      name      = "SPRING_DATASOURCE_URL"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:jdbc_url::"
    }, {
      name      = "SPRING_DATASOURCE_USERNAME"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
    }, {
      name      = "SPRING_DATASOURCE_PASSWORD"
      valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "poller"
      }
    }
  }])
}
