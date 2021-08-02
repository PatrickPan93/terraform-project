locals {
  ssh_port = "22"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  server_port = 8080
}
# 定义AWS ASG 创建所使用模板配置
resource "aws_launch_configuration" "example" {
  name_prefix     = "${var.cluster_name}-asg-configuration-"
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  # 引用被渲染后的shell脚本作为user_data
  user_data = var.user_data
  lifecycle {
    # 先创建替换资源, 再删除旧有资源
    create_before_destroy = true
  }

}

# 定义AWS ASG
resource "aws_autoscaling_group" "example" {
  # 这里有意的将ASG名称依赖于启动配置的名称,是为了每次启动配置更新时,都会使asg一并更新
  name                 = "${var.cluster_name}-asg-${aws_launch_configuration.example.name}"
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.example.name
  min_size             = var.min_size
  max_size             = var.max_size
  health_check_type    = var.health_check_type
  target_group_arns    = [var.target_group_arn]
  # 只有当健康检查的服务器到达以下数目时,才能判断ASG部署完成
  min_elb_capacity = var.min_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    # 先创建替换资源, 再删除旧有资源
    create_before_destroy = true
  }

}

# asg scaling
resource "aws_autoscaling_schedule" "scale_out_during_bussiness_hours" {
  count                 = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.max_size
  recurrence            = "0 9 * * *"
  # 组名是通过module中的output获取
  autoscaling_group_name = aws_autoscaling_group.example.name
}
# asg scaling
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                 = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale_in_at_night"
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.min_size
  recurrence            = "0 17 * * *"
  # 组名是通过module中的output获取
  autoscaling_group_name = aws_autoscaling_group.example.name
}
# 为集群创建CPU告警
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}
# 为集群创建CPU积分告警,而积分机制只在t开头的类型实例中才存在,所以通过取instance_type的第一个字符进行判断,如果为t开头则引用该监控
resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count       = format("%.1s", var.instance_type) == "t" ? 1 : 0
  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
# 定义安全组
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance-security-group"

  /*
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  */
}
resource "aws_security_group_rule" "allow_http_80_port_external" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}
resource "aws_security_group_rule" "allow_http_8080_port_external" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port = local.server_port
  to_port = local.server_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}