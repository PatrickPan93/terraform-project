variable "alb_name" {
  description = "The Name of this elb"
  type        = string
}
variable "alb_public_port" {
  description = "The port the alb will use for HTTP requests"
  type        = number
}
variable "subnet_ids" {
  description = "The subnets for alb"
  type = list(string)
}
variable "target_group_arn" {
  description = "the ARn of aws_lb_target_group"
  type = string
}