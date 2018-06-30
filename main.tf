/*
terraform {
  required_version = ">=0.9.6",
  backend "s3" {
    key    = "terraform.tfstate"
  }
}
*/
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "terraform_${var.emailid}"
  }

  #With timestamp
  /*
    tags {
    Name = "terraform_${var.emailid}_${timestamp()}"
  }
  */
}

resource "aws_subnet" "f5-management-a" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags {
    Name = "management"
  }
}

resource "aws_subnet" "f5-management-b" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags {
    Name = "management"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags {
    Name = "public"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags {
    Name = "private"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}b"

  tags {
    Name = "public"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id                  = "${aws_vpc.terraform-vpc.id}"
  cidr_block              = "10.0.200.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}b"

  tags {
    Name = "private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  tags {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Default"
  }
}

resource "aws_main_route_table_association" "association-subnet" {
  vpc_id         = "${aws_vpc.terraform-vpc.id}"
  route_table_id = "${aws_route_table.rt1.id}"
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.emailidsan}"
}

resource "aws_cloudwatch_log_stream" "log-stream" {
  name           = "log-stream"
  log_group_name = "${aws_cloudwatch_log_group.log-group.name}"
}
resource "aws_security_group" "instance" {
  name   = "terraform-example-instance"
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "example-a" {
  count = 1

  #ami                    = "${var.web_server_ami}"
  ami                         = "${lookup(var.web_server_ami, var.aws_region)}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.public-a.id}"
  vpc_security_group_ids      = ["${aws_security_group.instance.id}"]
  key_name                    = "${var.aws_keypair}"
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              /sbin/chkconfig --add docker
              service docker start
              docker run -d -p 80:80 --net host -e F5DEMO_APP=website -e F5DEMO_NODENAME="Public Cloud Lab: AZ #1" --restart always --name f5demoapp chen23/f5-demo-app:latest
              EOF

  tags {
    Name   = "web-az1.${count.index}: ${var.emailidsan}"
    findme = "web"
  }
}

resource "aws_instance" "example-b" {
  count = 1

  #ami                    = "{var.web_server_ami}"
  ami                         = "${lookup(var.web_server_ami, var.aws_region)}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.public-b.id}"
  vpc_security_group_ids      = ["${aws_security_group.instance.id}"]
  key_name                    = "${var.aws_keypair}"
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              /sbin/chkconfig --add docker
              service docker start
              docker run -d -p 80:80 --net host -e F5DEMO_APP=website -e F5DEMO_NODENAME="Public Cloud Lab: AZ #2" --restart always --name f5demoapp chen23/f5-demo-app:latest
              EOF

  tags {
    Name   = "web-az2.${count.index}: ${var.emailidsan}"
    findme = "web"
  }
}

#data "aws_availability_zones" "all" {}

resource "aws_iam_server_certificate" "elb_cert" {
  name             = "elb_cert_${var.emailid}"
  certificate_body = "${file("${var.emailidsan}.crt")}"
  private_key      = "${file("${var.emailidsan}.key")}"
}

resource "aws_lb" "front_end" {
  name = "tf-alb-${var.emailidsan}"
  internal           = false
  load_balancer_type = "application"
  security_groups           = ["${aws_security_group.elb.id}"]
  subnets                   = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]

  tags {
    Name = "tf-alb-${var.emailidsan}"
  }
}

resource "aws_alb_target_group_attachment" "example-a" {
  target_group_arn = "${aws_alb_target_group.alb_target.arn}"
  target_id        = "${aws_instance.example-a.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "example-b" {
  target_group_arn = "${aws_alb_target_group.alb_target.arn}"
  target_id        = "${aws_instance.example-b.id}"
  port             = 80
}

resource "aws_alb_target_group" "alb_target" {  
  name     = "web-servers"  
  port     = "80"  
  protocol = "HTTP"  
  vpc_id   = "${aws_vpc.terraform-vpc.id}"
    tags {    
    name = "web-servers"    
  }   
}

resource "aws_alb_listener" "front_end" {  
  load_balancer_arn = "${aws_lb.front_end.arn}"  
  port              = "443"  
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_iam_server_certificate.elb_cert.arn}"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_target.arn}"
    type             = "forward"  
  }
}

resource "aws_security_group" "elb" {
  name   = "terraform-example-elb"
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "f5_management" {
  name   = "f5_management"
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "f5_data" {
  name   = "f5_data"
  vpc_id = "${aws_vpc.terraform-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 1026
    to_port     = 1026
    protocol    = "udp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 4353
    to_port     = 4353
    protocol    = "tcp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = "${var.restrictedSrcAddress}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
