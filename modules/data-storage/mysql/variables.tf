variable "db_password" {
  type        = string
  description = "The password for the database"
}
variable "user_name" {
  type = string
  description = "The username for the database"
}
variable "database_name" {
  type = string
  description = "The name for the instance"
}
variable "instance_type" {
  type = string
  description = "The type for the db instance"
  #"db.t2.micro"
}
variable "allocated_storage" {
  type = number
  description = "The allocated GBs for the db"
}
variable "environment" {
  type = string
  description = "The environment you deploy to"
}
variable "dynamodb_table_name" {
  type =string
  description = "The dynamodb table name"
}