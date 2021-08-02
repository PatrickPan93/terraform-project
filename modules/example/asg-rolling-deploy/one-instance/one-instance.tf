provider "aws" {
  region = "us-east-2"
}

locals {
  environment   = "unit-test"
  ami           = "ami-0c55b159cbfafe1f0"
  user_data     = data.template_file.user_data.rendered
  instance_type = "t2.micro"
  min_size      = 1
}
# 读取shell脚本进行渲染
data "template_file" "user_data" {
  // 用module的path来补全引用路径
  template = file("${path.module}/user-data.sh")
  vars = {
    server_port = "8080"
    server_text = "one-instance"
  }
}

# 开启读取aws_vpc数据开关
data "aws_vpc" "default" {
  default = true
}
# 从aws返回信息中获取子网id
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "asg" {
  source       = "../../../cluster/asg-rolling-deploy"
  cluster_name = "hello-world-${local.environment}"
  ami          = local.ami
  user_data    = local.user_data

  instance_type      = local.instance_type
  min_size           = local.min_size
  max_size           = local.min_size
  enable_autoscaling = false
  subnet_ids         = data.aws_subnet_ids.default.ids
  target_group_arn = ""
}