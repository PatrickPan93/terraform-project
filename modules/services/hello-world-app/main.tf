locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-patrick-pan"
    key            = "${var.environment}/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
# 通过s3 bucket的mysql status文件获取mysql信息
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    region = "us-east-2"
    key    = var.db_remote_state_key
  }
}
# 开启读取aws_vpc数据开关
data "aws_vpc" "default" {
  default = true
}
# 从aws返回信息中获取子网id
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
# 读取shell脚本进行渲染
data "template_file" "user_data" {
  // 用module的path来补全引用路径
  template = file("${path.module}/user-data.sh")
  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }
}
# 定义alb的转发target group
resource "aws_lb_target_group" "asg" {
  name     = "hello-world-${var.environment}"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name       = "hello-world-${var.environment}"
  ami                = var.ami
  user_data          = data.template_file.user_data.rendered
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = false
  subnet_ids         = data.aws_subnet_ids.default.ids
  target_group_arn  = aws_lb_target_group.asg.arn
  health_check_type  = "ELB"
  custom_tags        = var.custom_tags
}

module "alb" {
  source = "../../../modules/networking/alb"
  alb_name = "${var.environment}-alb"
  alb_public_port = var.public_port
  subnet_ids = data.aws_subnet_ids.default.ids
  target_group_arn = aws_lb_target_group.asg.arn
}

# 创建监听器规则,将所有部分联系在一起
resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }

  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

