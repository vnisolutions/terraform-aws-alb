resource "aws_lb" "alb" {
  name               = "${var.env}-${var.project_name}-${var.service_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.sg-alb[*].id
  subnets            = var.subnet_ids
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}-alb"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_lb_target_group" "alb-tg" {
  name        = "${var.env}-${var.project_name}-${var.service_name}-tg"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}-tg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_lb_listener" "alb-443" {
  count             = var.is_https ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "listener-rule" {
  count        = var.is_https ? 1 : 0
  listener_arn = aws_lb_listener.alb-443.*.id[0]
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "listener-rule-www" {
  count        = var.is_https ? 1 : 0
  listener_arn = aws_lb_listener.alb-443.*.id[0]
  action {
    type = "redirect"

    redirect {
      host        = var.domain
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  condition {
    host_header {
      values = ["www.${var.domain}"]
    }
  }
}

resource "aws_lb_listener" "alb-80" {
  count             = var.is_https ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb-http" {
  count             = var.is_https == false ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

# --- ALB Security Group  ---
resource "aws_security_group" "sg-alb" {
  name        = "${var.env}-${var.project_name}-${var.service_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = var.cidr_ingress
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = var.sg_ingress
      self             = null
    },
    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = var.cidr_ingress
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = var.sg_ingress
      self             = null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null

    }
  ]

  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}-alb-sg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}
