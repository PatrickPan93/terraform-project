# 开启读取aws_vpc数据开关
data "aws_vpc" "default" {
  default = true
}
# 从aws返回信息中获取子网id
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "alb" {
  source = "../../../modules/networking/alb"
  alb_name = "alb"
  subnet_ids = data.aws_subnet_ids.default.ids
  alb_public_port = 80
}