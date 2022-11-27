terraform {
    required_version = "~>1.3.0"
#    required_providers {
#        aws = {
#            source = "hshicorp/aws"
#            version = "~>4.41.0"
#        }
#    }
}

provider "aws" {
    profile = "default"
    region = "${var.aws_region}"
}
