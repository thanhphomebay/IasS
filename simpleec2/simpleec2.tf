provider "aws" {
  region = "us-east-2"
  profile = "default"
}

variable "prefix" {
  description = "web prefix"
  default = "webserver"
}

resource "aws_instance" "web" {
  ami           = "ami-07693758d0ebc2111"
  instance_type = "t2.micro"
  count = 1
  vpc_security_group_ids = [
    "sg-03fde1e02c0cb403c"
  ]
  user_data = <<EOF
#! /bin/sh
# get admin privileges
sudo su

# install httpd (Linux 2 version)
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from $(hostname -f)” > /var/www/html/index.html
EOF
  subnet_id = "subnet-0e163dca415435662"
  tags = {
    Name = "${var.prefix}${count.index}"
  }
}

output "instances" {
  value       = "${aws_instance.web.*.private_ip}"
  description = "PrivateIP address details"
}
