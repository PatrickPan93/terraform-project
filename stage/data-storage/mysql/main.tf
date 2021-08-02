provider "aws" {
  region = "us-east-2"
}

locals {
  environment = "stage"
  dynamodb_table = "terraform-up-and-running-locks"
  instance_type = "db.t2.micro"
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-patrick-pan"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "mysql" {
  source = "../../../modules/data-storage/mysql"
  allocated_storage = 10
  database_name = "MySqlForStage"
  db_password = "password"
  environment = local.environment
  instance_type = local.instance_type
  user_name = "username"
  dynamodb_table_name = local.dynamodb_table
}