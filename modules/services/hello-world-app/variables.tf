variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}
variable "server_text" {
  description = "The Server text for website"
  type        = string
}

variable "environment" {
  description = "The name of environment we're deploying to"
  type        = string
}
variable "instance_type" {
  description = "instance_type"
  type        = string
}
variable "min_size" {
  description = "min_size"
  type        = string
}
variable "max_size" {
  description = "max_size"
  type        = string
}
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}
# 定义本代码块所使用变量
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
}
variable "public_port" {
  description = "The port the server will use for HTTP requests external"
  type        = number
}
variable "ami" {
  description = "The OS Image for the asg"
  type =  string
}
variable "db_remote_state_bucket" {
  description = "db_remote_state_bucket"
  type = string
}