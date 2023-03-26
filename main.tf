provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = "eu-west-3"
}

resource "aws_vpc" "vpc" {
cidr_block = "10.0.0.0/16"
instance_tenancy        = "default"
enable_dns_hostnames    = true
tags      = {
Name    = "PythonApp_VPC"
}
}

resource "aws_internet_gateway" "internet-gateway" {
vpc_id    = aws_vpc.vpc.id
tags = {
Name    = "PythonApp_gateway"

}
}
resource "aws_subnet" "public-subnet-1" {
vpc_id                  = aws_vpc.vpc.id
cidr_block              = "10.0.0.0/24"
availability_zone       = "eu-west-3a"
map_public_ip_on_launch = true
tags      = {
Name    = "PythonApp_public-subnet-1"
}
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
vpc_id       = aws_vpc.vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.internet-gateway.id
}
tags       = {
Name     = "Public Route Table for Python App"
}
}

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
subnet_id           = aws_subnet.public-subnet-1.id
route_table_id      = aws_route_table.public-route-table.id
}

#resource "tls_private_key" "example" {
#  algorithm = "ED25519"
#  rsa_bits  = 4096
#}

#variable "key_name" {}

#resource "tls_private_key" "example" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

#resource "aws_key_pair" "generated_key" {
#  key_name   = var.key_name
#  public_key = tls_private_key.example.public_key_openssh
#}
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

#resource "aws_key_pair" "generated_key" {
#  key_name   = "phrase_admin"
#  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVik0lgchdHNTiaWjk1fxLeJfVswaj53AhZ10C386UB phrase_admin"
#}

#resource "aws_key_pair" "generated_key1" {
#  key_name   = "phrase_user"
#  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvYQmQpRjxwculU+JjHYN7g7FDeS04MA6x67Q2SD0dZ phrase_user"
#}

# Create Security Group for the Bastion Host aka Jump Box
# terraform aws create security group
resource "aws_security_group" "flask-security-group" {
name        = "SSH Security Group"
description = "Enable SSH access on Port 22"
vpc_id      = aws_vpc.vpc.id
ingress {
description      = "SSH Access"
from_port        = 22
to_port          = 22
protocol         = "tcp"
cidr_blocks      = ["0.0.0.0/0"]
}
egress {
from_port        = 0
to_port          = 0
protocol         = "-1"
cidr_blocks      = ["0.0.0.0/0"]
}
ingress {
    description      = "HTTPS Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
ingress {
    description      = "HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
tags   = {
Name = "Flask Security Group"
}
}
data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Create a new EC2 launch configuration
resource "aws_instance" "flask-app" {
ami                    = data.aws_ami.ubuntu-linux-2004.id
instance_type               = var.instance
#availability_zone           = var.region           
key_name      = "tf-key-pair"
security_groups             = ["${aws_security_group.flask-security-group.id}"]
subnet_id                   = "${aws_subnet.public-subnet-1.id}"
associate_public_ip_address = true
lifecycle {
create_before_destroy = true
}
tags = {
"Name" = "flask-APP"
}
user_data = <<-EOF
    #!/bin/bash
    sudo useradd -m phrase_admin
    sudo useradd -m phrase_user
    sudo mkdir -p /home/phrase_admin/.ssh
    sudo mkdir -p /home/phrase_user/.ssh
    sudo passwd -d phrase_admin
    sudo apt update -y
    sudo apt install curl jq -y
    sudo apt install apt-transport-https ca-certificates curl software-properties-common jq -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    apt-cache policy docker-ce
    sudo apt install docker-ce docker-compose -y
    sudo usermod -aG docker ubuntu
    sudo usermod -aG docker phrase_admin
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexRNL1fxnMBcHQeG5zffduJ7L8+63Iqkkb2y7K+WkWQDQX6vqJ39MGnZ8bVj69drDn35Rifd3dunOsb4YUUysWO6mLwNZvVLg3AQsmY2l77teq233EWSy9hH4fM+dazIALY5olAuy38loQgZvl8WXyxFVs7hPjo5/zAvl5Kt83czniyFvLsS1YhXiARcey8f9Tw9EZzRDzISR2hmvrONFNA8IlU6LSQZp6ab6Up/n3/2VCupv9tLCXQHlPsQV+5ZjnOYuvqv1QIlq5cNG6QmSZ6kQ8/WpyqNatTvVAB9dRjNSBjZZ4EodWYzQ8Q8Km9eF/Z4acE20DI2/UMRkqvM3 rsa-key-20230327" >> /home/ubuntu/.ssh/authorized_keys
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVik0lgchdHNTiaWjk1fxLeJfVswaj53AhZ10C386UB phrase_admin" >> /home/phrase_admin/.ssh/authorized_keys
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvYQmQpRjxwculU+JjHYN7g7FDeS04MA6x67Q2SD0dZ phrase_admin" >> /home/phrase_user/.ssh/authorized_keys
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVik0lgchdHNTiaWjk1fxLeJfVswaj53AhZ10C386UB phrase_admin" >> /home/ubuntu/.ssh/authorized_keys
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvYQmQpRjxwculU+JjHYN7g7FDeS04MA6x67Q2SD0dZ phrase_admin" >> /home/ubuntu/.ssh/authorized_keys
    chmod 644 /home/phrase_admin/.ssh/authorized_keys
    chmod 644 /home/phrase_user/.ssh/authorized_keys
    chmod 644 /home/ubuntu/.ssh/authorized_keys
    chown -R phrase_user:phrase_user .ssh
    chown -R phrase_admin:phrase_admin .ssh
  EOF
}