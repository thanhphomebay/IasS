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
    us-west-1 = "ami-bogus-for-us-west"
    us-east-2 = "ami-07693758d0ebc2111"
  }
}
variable "public_subnet" {
  description = "get the info from network module output"
  type=list
}

variable "private_subnet" {
  description = "get the info from network module output"
  type=list
}

variable "vpc_id" {
  description = "get the info from network module output"
  type=string
}

variable "server_port" {
  description = "either 80 or 443"
  type=number
}

variable "server_port_protocol" {
  description = "Either http or https"
  type=string
}
