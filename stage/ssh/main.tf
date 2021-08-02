provider "aws" {
  region = "us-east-2"
}

locals {
  asg_resource_name = "aws_security_group"
  ssh_port = 22
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
  environment = "stage"
}
resource "aws_security_group" "ssh" {
  name = "${var.environment}-${local.asg_resource_name}"
}

//TODO: params
resource "aws_security_group_rule" "ssh_rule" {
  type = "ingress"
  security_group_id = aws_security_group.ssh.id
  from_port = local.ssh_port
  to_port = local.ssh_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}
resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

resource "aws_instance" "example" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name = aws_key_pair.generated_key.key_name

  provisioner "remote-exec" {
    inline = ["echo \"Hello, World from $(uname -smp)\""]
  }
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = tls_private_key.ssh_private_key.private_key_pem
  }
}

// null_resource allow us do something without creating any resource
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo \"Hello World\""
  }
}