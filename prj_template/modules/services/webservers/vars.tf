variable "env" {
  type= string
}
variable "region" {
  description = "AWS deployment region..."
  default = "us-east-2"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
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

variable "AMI" {
  type = map(string)

  default = {
    us-west-1 = "ami-bogus"
    us-east-2 = "ami-07693758d0ebc2111"
  }
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}
