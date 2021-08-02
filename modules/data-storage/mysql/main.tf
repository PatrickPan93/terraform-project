provider "aws" {
  region = "us-east-2"
}

/*
terraform {
  backend "s3" {
    bucket         = var.state_bucket_name_s3
    key            = var.state_bucket_key_s3
    region         = "us-east-2"
    dynamodb_table = var.dynamodb_table_name
    encrypt        = true
  }
}
*/
resource "aws_db_instance" "example" {
  identifier_prefix = "${var.environment}-terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = var.allocated_storage
  instance_class    = var.instance_type
  name              = var.database_name
  username          = var.user_name
  password          = var.db_password
  # 被删除时不创建快照
  skip_final_snapshot = true
}