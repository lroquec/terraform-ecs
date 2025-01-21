resource "aws_iam_role" "external_dns" {
  name = "external-dns-role"

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

resource "aws_iam_role_policy" "external_dns" {
  name = "external-dns-policy"
  role = aws_iam_role.external_dns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/ecs/external-dns*",
          "arn:aws:logs:*:*:log-group:/ecs/external-dns*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_ecs_task_definition" "external_dns" {
  family                   = "external-dns"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.external_dns.arn
  task_role_arn            = aws_iam_role.external_dns.arn

  container_definitions = jsonencode([
    {
      name  = "external-dns"
      image = "registry.k8s.io/external-dns/external-dns:${var.external_dns_image}"
      command = [
        "--source=ecs",
        "--domain-filter=${var.external_dns_domain_filter}",
        "--provider=aws",
        "--policy=sync",
        "--aws-zone-type=public",
        "--txt-owner-id=${var.ecs_cluster_name}"
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/external-dns"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_security_group" "external_dns" {
  name        = "external-dns-sg"
  description = "Security group for External DNS"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "external_dns" {
  name            = "external-dns"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.external_dns.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.external_dns.id]
  }
}

resource "aws_cloudwatch_log_group" "external_dns" {
  name              = "/ecs/external-dns"
  retention_in_days = 7
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-external-dns-logs"
  })
}