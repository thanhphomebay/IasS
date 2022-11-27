variable "prefix" {
  description = "web prefix"
  default = "webserver"
}

resource "aws_instance" "web" {
  ami           = "${lookup(var.AMI,var.AWS_REGION)}"
  instance_type = "t2.micro"
  count = 1

  #VPC
  subnet_id="${aws_subnet.prod-subnet-public-1.id}"

  #Secrity group
  vpc_security_group_ids=["${aws_security_group.sg-ssh-allowed.id}"]

  #ssh key
  key_name="sshanna"

  

  user_data = <<EOF
#!/bin/bash
yum update -y 
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from $(hostname -f)” > /var/www/html/index.html
EOF

  tags = {
    Name = "${var.prefix}${count.index}"
  }
}

resource "aws_instance" "mongodb" {
  ami = "${lookup(var.AMI,var.AWS_REGION)}"
  instance_type = "t2.micro"
  count = 1

  #VPC
  subnet_id= "${aws_subnet.prod-subnet-private-1.id}"
  
  #security group
  vpc_security_group_ids = ["${aws_security_group.sg-ssh-allowed.id}"]

  #ssh key
  key_name = "sshanna"

  tags = {
    Name = "mongodb"
  }
}

output "instances" {
  value       = "${aws_instance.web.*.private_ip}"
  description = "PrivateIP address details"
}
