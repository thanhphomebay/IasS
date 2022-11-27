variable "prefix" {
  description = "web prefix"
  default = "webserver"
}


resource "aws_instance" "web" {
  ami           = "${lookup(var.AMI,var.region)}"
  instance_type = "t2.micro"
  count = "${length(var.public_subnet)}"

  #VPC
  subnet_id="${element(var.public_subnet,count.index)}"

  #Secrity group
  vpc_security_group_ids=["${aws_security_group.sg-tf-ssh-allowed.id}"]

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
    Name = "${var.env}-${var.prefix}${count.index}"
    Env = "${var.env}"
  }
}

resource "aws_instance" "mongodb" {
  ami = "${lookup(var.AMI,var.region)}"
  instance_type = "t2.micro"
  count = "${length(var.private_subnet)}"

  #VPC
  subnet_id= "${element(var.private_subnet,count.index)}"
  
  #security group
  vpc_security_group_ids = ["${aws_security_group.sg-tf-ssh-allowed.id}"]

  #ssh key
  key_name = "sshanna"

  tags = {
    Name = "${var.env}-mongodb"
  }
}

resource "aws_security_group" "sg-tf-ssh-allowed" {
  vpc_id="${var.vpc_id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks=["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks=["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-sg-ssh-allowed"
    Env = "${var.env}"
  }
}

