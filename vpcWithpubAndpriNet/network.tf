resource "aws_internet_gateway" "prod-igw" {
  vpc_id = "${aws_vpc.prod-vpc.id}"

  tags = {
    Name = "prod-igw"
  }
}


resource "aws_route_table" "prod-public-crt" {
  vpc_id ="${aws_vpc.prod-vpc.id}" //using main vpc
  
  route {
    cidr_block="0.0.0.0/0"
    gateway_id="${aws_internet_gateway.prod-igw.id}"
  }

  tags = {
    Name ="prod-public-crt"
  }
}


//Associate route table with subnet
resource "aws_route_table_association" "prod-crta-public-subnet-1" {
  subnet_id="${aws_subnet.prod-subnet-public-1.id}"
  route_table_id="${aws_route_table.prod-public-crt.id}"

}

resource "aws_security_group" "sg-ssh-allowed" {
  vpc_id="${aws_vpc.prod-vpc.id}"
  
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
    cidr_blocks=["204.235.229.17/32"]
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
    Name = "sg-ssh-allowed"
  }
}
