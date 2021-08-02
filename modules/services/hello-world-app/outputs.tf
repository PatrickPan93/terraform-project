# 输出信息
#output "public_ip" {
#  value       = aws_instance.app[0].public_ip
#  description = "The public IP address of the web server"
#}
#output "sub_net_id" {
#  value = data.aws_subnet_ids.default.ids
#}

/*
output "alb_dns_name" {
  value = module.alb.alb_dns_name

}
output "asg_name" {
  value = module.asg.asg_name
}

output "instance_security_group_id" {
  value = module.asg.instance_security_group_id
}

output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.asg.arn
}
*/