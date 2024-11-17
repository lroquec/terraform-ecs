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

resource "aws_security_group" "allow_container_inbound" {
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
  security_group_id = aws_security_group.allow_container_inbound.id
}

resource "aws_security_group_rule" "allow_container_inbound" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_container_inbound.id
}

# ALB Resources
resource "aws_lb" "main" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_inbound.id]
  subnets           = module.vpc.public_subnets

  idle_timeout = 60

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-alb"
  })
}
