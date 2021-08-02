provider "aws" {
  region     = "us-east-2"
}
terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-patrick-pan"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
    #profile        = "terraform.tfstate"
  }
}
resource "aws_s3_bucket" "terraform_state" {

  bucket = "terraform-up-and-running-state-patrick-pan"

  # prevent deleting option
  lifecycle {
    prevent_destroy = true
  }

  # version controll enabled
  versioning {
    enabled = true
  }

  # encryption 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# 通过dynamodb实现terraform的状态文件分布式锁
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
