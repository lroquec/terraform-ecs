# Security Groups
resource "aws_security_group" "allow_http_inbound" {
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-allow-http-sg"
  })
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http_inbound.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http_inbound.id
}

resource "aws_security_group" "allow_container" {
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-allow-http-sg"
  })
}

resource "aws_security_group_rule" "allow_container_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_container.id
}

resource "aws_security_group_rule" "allow_container_inbound" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_http_inbound.id # Allow traffic from the ALB
  security_group_id        = aws_security_group.allow_container.id
}

# ALB Resources
resource "aws_lb" "main" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_inbound.id]
  subnets            = module.vpc.public_subnets

  idle_timeout = 60

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-alb"
  })
}

resource "aws_lb_target_group" "main" {
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-tg"
  })
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Data sources for ECS resources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ECS Resources
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecs-cluster"
  })
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/app/ecs/${var.project_name}"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecs-logs"
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ECSExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "ECSExecutionPolicy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup"]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/app/ecs/${var.project_name}*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.task_definition_family
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  track_latest             = true

  container_definitions = jsonencode([
    {
      name  = "MyContainer"
      image = var.container_image
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.allow_container.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "MyContainer"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.front_end]

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ecs-service"
  })
}