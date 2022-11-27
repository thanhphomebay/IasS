variable "env" {
  type= string
  default="development"
}
variable "region" {
  description = "AWS deployment region..."
  default = "us-east-2"
}

variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

variable "public_subnets_cidr" {
  type=list
  default= ["10.10.0.0/25","10.10.0.128/25"]
}
variable "private_subnets_cidr" {
  type=list
  default = ["10.10.1.0/25","10.10.1.128/25"]
}

variable "availability_zones" {
  type=list
  default =["us-east-2a","us-east-2b","us-east-2c"]
}

