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
}
resource "aws_launch_configuration" "asg-launch-config" {
  name = "asg-launch-config"
  image_id = "${lookup(var.AMI,var.region)}"
  instance_type = "t2.micro"
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
  name                 = "asg-tf"
  launch_configuration = "${aws_launch_configuration.asg-launch-config.name}"
  min_size             = 2
  max_size             = 2
  vpc_zone_identifier = "${var.public_subnet}"

  target_group_arns = [aws_lb_target_group.alb-target-group.arn]
  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

/*******application load balancer *******************/
resource "aws_lb" "this" {
  name = "tf-sg-alb"
  load_balancer_type = "application"
  subnets = "${var.public_subnet}"
  security_groups =["${aws_security_group.tf-sg-alb.id}"]
  tags = {
    Name = "${var.env}-alb"
    Env = "${var.env}"
  }
  #tags = merge({ "ResourceName" = ${var.project_name}" }, var.tags)
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.this.arn
  port  = "${var.server_port}"
  protocol = "${var.server_port_protocol}"

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
  #tags = merge({ "ResourceName" = ${var.project_name}" }, var.tags)
}

resource "aws_lb_target_group" "alb-target-group" {
  name = "alb-target-group"
  port = "${var.server_port}"
  protocol = "${var.server_port_protocol}"
  vpc_id = "${var.vpc_id}" 

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
    name = "tf-sg-alb"
    vpc_id = "${var.vpc_id}"
  # Allow inbound HTTP requests
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
