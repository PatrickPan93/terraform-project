provider "aws" {
  region = "us-east-2"
}

module "mysql" {
  source = "../../../modules/data-storage/mysql"
  allocated_storage = 10
  database_name = "MysqlForUnit"
  db_password = "password"
  instance_type = "db.t2.micro"
  user_name = "username"
  environment = "unit-test"
  state_bucket_name_s3 = ""
  dynamodb_table_name = ""
  state_bucket_key_s3 = ""
}