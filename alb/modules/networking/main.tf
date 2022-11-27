/* VPC */

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  tags = {
    Name = "${var.env}-vpc"
    Env = "${var.env}"
  }
}

/* gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.env}-igw"
    Env = "${var.env}"
  }
}
/* routing table for public subnet */
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "${var.env}-public-route-table"
    Env = "${var.env}"
  }
}
/* route table associations for public subnet */
resource "aws_route_table_association" "public_rta" {
  count = "${length(var.public_subnets_cidr)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}



resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.public_subnets_cidr)}"
  cidr_block = "${element(var.public_subnets_cidr,count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-${element(var.availability_zones,count.index)}-public_subnet"
    Env = "${var.env}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.private_subnets_cidr)}"
  cidr_block = "${element(var.private_subnets_cidr,count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false 
  tags = {
    Name = "${var.env}-${element(var.availability_zones,count.index)}-private_subnet"
    Env = "${var.env}"
  }
}

/****************VPC's default security group *************/
resource "aws_security_group" "sg_vpc_default" {
  name = "${var.env}-sg-vpc-default"
  vpc_id = "${aws_vpc.vpc.id}"
  //depends_on = [aws_vpc.vpc]
    ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Env   = "${var.env}"
  }
}
