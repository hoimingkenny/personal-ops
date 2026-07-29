# EventBridge → ECS RunTask — scheduled connector polls.
# See docs/adr/0004-aws-eventbridge-ecs-poll-scheduling.md

resource "aws_cloudwatch_event_rule" "poll_schedule" {
  name                = "${var.project_name}-${var.environment}-poll-schedule"
  description         = "Trigger one-shot ECS poller tasks for Personal Ops OS"
  schedule_expression = var.poll_schedule_expression

  tags = {
    Name = "${var.project_name}-${var.environment}-poll-schedule"
  }
}

resource "aws_cloudwatch_event_target" "poll_ecs" {
  rule      = aws_cloudwatch_event_rule.poll_schedule.name
  target_id = "poll-ecs-run-task"
  arn       = aws_ecs_cluster.main.arn
  role_arn  = aws_iam_role.eventbridge_ecs.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.poller.arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets          = aws_subnet.private[*].id
      security_groups  = [aws_security_group.ecs_tasks.id]
      assign_public_ip = false
    }
  }

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 2
  }
}

resource "aws_iam_role" "eventbridge_ecs" {
  name = "${var.project_name}-${var.environment}-eventbridge-ecs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eventbridge-ecs"
  }
}

resource "aws_iam_role_policy" "eventbridge_ecs_run_task" {
  name = "${var.project_name}-${var.environment}-eventbridge-run-task"
  role = aws_iam_role.eventbridge_ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ecs:RunTask"]
        Resource = [
          aws_ecs_task_definition.poller.arn
        ]
        Condition = {
          ArnLike = {
            "ecs:cluster" = aws_ecs_cluster.main.arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.ecs_task.arn
        ]
      }
    ]
  })
}
