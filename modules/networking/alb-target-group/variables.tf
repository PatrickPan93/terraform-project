variable "environment" {
  description = "The Environment you deploy to"
  type = string
}
variable "vpc_id" {
  description = "VPC id"
  type =string
}
variable "name" {
  description = "name of target group name"
  type = string
}
variable "service_port" {
  description = "the app port of asg's discovery"
  type = number
}