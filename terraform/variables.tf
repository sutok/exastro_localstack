variable "region" {
  default = "ap-northeast-1"
}

variable "project" {
  default = "myapp"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_app_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet_db_cidr" {
  default = "10.0.3.0/24"
}

variable "ami_id" {
  default = "ami-0abcdef1234567890"
}

variable "instance_type" {
  default = "t3.micro"
}
