variable "ami_id" {
  type    = string
  default = "ami-0557a15b87f6559cf"
}

variable "access_key" {
    type = string
    default = "XXXXXXXXXXXXXXXXX"
}

variable "secret_key" {
    type = string
    default = "xxxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "instance" {
  type    = string
  default = "t2.micro"
}

variable "region" {
    type = string
    default = "us-west-3"
}

variable "key_name" {
    type = string
    default = "phrase_admin"
}

variable "vpc-cidr" {
default = "10.0.0.0/16"
description = "VPC CIDR BLOCK"
type = string
}
variable "Public_Subnet_1" {
default = "10.0.0.0/24"
description = "Public_Subnet_1"
type = string
}
#variable "Private_Subnet_1" {
#default = "10.0.2.0/24"
#description = "Private_Subnet_1"
#type = string
#}
variable "ssh-location" {
default = "0.0.0.0/0"
description = "SSH variable for bastion host"
type = string
}
variable "instance_type" {
type        = string
default     = "t2.micro"
}
#variable key_name {
#default     = "LL-TEST"
#type = string
#}
variable "sg" {
  description = "List of Security Group IDs"
  type        = list(string)
  default     = [ "sg-111436g6535hc63xc" ]
}
