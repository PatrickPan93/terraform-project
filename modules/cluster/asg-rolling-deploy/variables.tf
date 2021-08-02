variable "ami" {
  description = "The Aim cluster use with"
  type        = string
}
variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}
variable "instance_type" {
  description = "instance_type"
  type        = string
}
variable "min_size" {
  description = "min_size"
  type        = number
}
variable "max_size" {
  description = "max_size"
  type        = number
}
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}
variable "enable_autoscaling" {
  description = "If set to true, enable autoscaling"
  type        = bool
}
# 定义本代码块所使用变量
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
variable "subnet_ids" {
  description = "The subNet IDs to deploy to"
  type        = list(string)
}
variable "target_group_arn" {
  description = "The ARn of ELB target Groups in which to register Instances"
  type        = string
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2 | ELB."
  type        = string
  default     = "EC2"
}

variable "user_data" {
  description = "The User Data Script to run in each Instance at boot"
  type        = string
  default     = ""
}
