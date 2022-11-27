////////////////////////////////////////////// VPC /////////////////////////////////////////////////////////////////////

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

resource "aws_security_group" "sg_vpc_default" {
  name = "${var.env}-${var.cluster_name}-sg-vpc-default"
  vpc_id = "${aws_vpc.vpc.id}"
  //depends_on = [aws_vpc.vpc]
    ingress {
    from_port = local.any_port
    to_port   = local.any_port
    protocol  = local.any_protocol
    self      = true
  }

  egress {
    from_port = local.any_port
    to_port   = local.any_port
    protocol  = local.any_protocol
    self      = "true"
  }
  tags = {
    Env   = "${var.env}"
  }
}

////////////////////////////////////////////// END OF VPC /////////////////////////////////////////////////////////////////////

/******************************************************** ALB **********************************************************/
/*resource "aws_security_group" "sg-tf-ssh-allowed" {
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
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
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
}*/
resource "aws_launch_configuration" "asg-launch-config" {
  name = "${var.env}-${var.cluster_name}-asg-launch-config"
  image_id = "${lookup(var.AMI,var.region)}"
  instance_type = "${var.instance_type}"
//  security_groups = ["${aws_security_group.sg-tf-ssh-allowed.id}"]
  security_groups = ["${aws_security_group.tf-sg-alb.id}"]

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

  lifecycle {
    create_before_destroy = true 
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.env}-${var.cluster_name}-asg-tf"
  launch_configuration = "${aws_launch_configuration.asg-launch-config.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  vpc_zone_identifier = "${aws_subnet.public_subnet.*.id}"

  target_group_arns = [aws_lb_target_group.alb-target-group.arn]
  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

/*******application load balancer *******************/
resource "aws_lb" "alb" {
  name = "${var.env}-${var.cluster_name}-tf-sg-alb"
  load_balancer_type = "application"
  subnets = "${aws_subnet.public_subnet.*.id}"
  security_groups =["${aws_security_group.tf-sg-alb.id}"]
  tags = {
    Name = "${var.env}-alb"
    Env = "${var.env}"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port  = local.http_port
  protocol = "HTTP"

  #return a simple 404 page  that don't match any listen rules
  default_action {
    type = "fixed-response" 

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

  tags = {
    Name = "${var.env}-http-listener"
    Env = "${var.env}"
  }
}

resource "aws_lb_target_group" "alb-target-group" {
  name = "${var.env}-${var.cluster_name}-alb-tg"
  port = local.http_port
  protocol = "HTTP"
  vpc_id = "${aws_vpc.vpc.id}"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.env}-alb-target-group"
    Env = "${var.env}"
  }

}
/********* combine everything together ****/
resource "aws_lb_listener_rule" "http-listener-rule" {
  listener_arn = aws_lb_listener.http-listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}

resource "aws_security_group" "tf-sg-alb" {
    name = "${var.env}-${var.cluster_name}-tf-sg-alb"
    vpc_id = "${aws_vpc.vpc.id}"
  # Allow inbound HTTP requests
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound requests
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}
