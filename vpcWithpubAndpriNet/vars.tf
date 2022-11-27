variable "AWS_REGION" {    
    description = "AWS Deployment region.."
    default = "us-east-2"
  } 

variable "AMI" {
  type = map(string)

  default = {
    us-west-1 = "ami-bogus"
    us-east-2 = "ami-07693758d0ebc2111"
  }
}

