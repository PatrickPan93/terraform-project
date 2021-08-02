locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}
# 定义ALB作为负载均衡
resource "aws_lb" "example" {
  name               = var.alb_name
  load_balancer_type = "application"
  # 通过子网来判断被负载均衡的对象
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.alb.id]
}
# 为ALB定义一个listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.alb_public_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
# security group for alb
resource "aws_security_group" "alb" {
  name = var.alb_name
  ingress {
    from_port   = var.alb_public_port
    to_port     = var.alb_public_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}
