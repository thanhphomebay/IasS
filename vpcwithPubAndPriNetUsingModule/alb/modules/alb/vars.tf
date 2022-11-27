variable "env" {
  type= string
  default="development"
}
variable "region" {
  description = "AWS deployment region..."
  default = "us-east-2"
}

variable "AMI" {
  type = map(string)

  default = {
    us-west-1 = "ami-bogus"
    us-east-2 = "ami-07693758d0ebc2111"
  }
}
variable "public_subnet" {
  type=list
  description = "get the info from network module output"
}

variable "private_subnet" {
  type=list
  description = "get the info from network module output"
}

variable "vpc_id" {
  type=string
}

variable "server_port" {
  type=number
}
