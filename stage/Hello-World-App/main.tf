provider "aws" {
  region = "us-east-2"
}
locals {
  environment = "stage"
  ami = "ami-0c55b159cbfafe1f0"
}
module "app" {
  source = "../../modules/services/hello-world-app"
  ami = local.ami
  db_remote_state_bucket = "terraform-up-and-running-state-patrick-pan"
  db_remote_state_key = "${local.environment}/data-stores/mysql/terraform.tfstate"
  environment = local.environment
  instance_type = "t2.micro"
  min_size = 2
  max_size = 5
  server_text = "test stage"
  server_port = 8080
  public_port = 80
}