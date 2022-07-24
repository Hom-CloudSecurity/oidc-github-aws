# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
      region = var.aws_region
    }
  }
required_version = ">= 1.2.0"
}

data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20200407",
    ]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfzuH3tMn7FRFfwReDJ/jgs2zeWjUNaeR7Jh6hTyS94N3YHpwoUba6HEOGZlnybzBXYGmpTOD7t+QcQZ9jwdH7nV28JtqqOBrLNqD6x3M5+pl7q+9cau+qnCqeTDosPIT8Hlxw0nvZLzC5Itct2zMMfKoSQEEPACPVpUnUeqbkspObWrkqA9J9P0LyKpaa0+KACMAwDl72tzNRT75+N4taIboq+cwF7QvDvimSZo9Wuztau5+dYvMztaa8MXJvEv73QBe1ED+ILmXjfb0D+hP87wSrfRl9KfwHlrKinI0gD0saP0TmLN2Q+WmNvisDMUFUDlhtDfHKGiNkFrBRUxuDZPBvb54+p7JIIae3J/EHFGIbdaPHb8w29HDHFfnj11a9utATxwcEle8ZHYMXNizA2IiWz0zxa/KhDa9X/N8VeY/iicWikbfwMKJbULVkCXkw7TM1UBMRo08i4Mt3hBohhANzOVHrGSf7eAkdTx+3qYXnmhgjbvMvEMxgRw9w3gU="
}

resource "aws_security_group" "security_group" {
  name = "sec_group_github_runner"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-instance" {
  vpc_security_group_ids = [aws_security_group.security_group.id]
  ami           = data.aws_ami.ubuntu_server.id
  instance_type = "t2.micro" ## Free tier
  associate_public_ip_address = true
  key_name="ssh-key"
  #user_data = base64encode(templatefile("${path.module}/scripts/ec2.tpl", {personal_access_token=var.personal_access_token}))
  #user_data = "${file("scripts/ec2.sh")}"	
	tags = {
		Name = "GitHub-Runner"	
		Type = "terraform"
	}
}
