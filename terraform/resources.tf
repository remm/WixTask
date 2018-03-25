data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "default" {
  ### Default VPC security group ###
  name        = "default"
  description = "default VPC security group"
  vpc_id      = "vpc-07cf417c"
}

resource "aws_security_group_rule" "default" {
  ### Default VPC security group rule ###
  security_group_id = "${aws_security_group.default.id}"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"

  self = true
}

resource "aws_security_group" "sg_access" {
  name        = "app_access"
  description = "Allow access instances thought 22 and 11000 ports"
  vpc_id      = "vpc-07cf417c"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${aws_security_group.sg_access.id}"

  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"

  cidr_blocks     = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "app" {
  security_group_id = "${aws_security_group.sg_access.id}"

  from_port         = 11000
  to_port           = 11000
  protocol          = "tcp"
  type              = "ingress"

  cidr_blocks     = ["0.0.0.0/0"]
}


resource "aws_instance" "web_a" {
### Instance a ###
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.web_subnet_a.id}"
  key_name = "aws_key"
  vpc_security_group_ids = ["${aws_security_group.sg_access.id}", "${aws_security_group.default.id}"]

  tags {
    Name = "web_a"
  }
}

resource "aws_instance" "web_b" {
### Instance b ###
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  availability_zone = "us-east-1b"
  subnet_id = "${aws_subnet.web_subnet_b.id}"
  key_name = "aws_key"
  vpc_security_group_ids = ["${aws_security_group.sg_access.id}", "${aws_security_group.default.id}"]

  tags {
    Name = "web_b"
  }
}


resource "aws_subnet" "web_subnet_a" {
  ### Subnet a ###
  vpc_id     = "vpc-07cf417c"
  cidr_block = "172.31.80.0/20"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "web_subnet_a"
  }
}

resource "aws_subnet" "web_subnet_b" {
  ### Subnet b ###
  vpc_id     = "vpc-07cf417c"
  cidr_block = "172.31.16.0/20"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Name = "web_subnet_b"
  }
}

resource "aws_lb" "balancer" {
  ### Network Load Balancer ###
  name            = "balancer-lb-tf"
  internal        = false
  // security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${aws_subnet.web_subnet_a.id}", "${aws_subnet.web_subnet_b.id}"]

  load_balancer_type = "network"

  tags {
    Environment = "balancer"
  }
}


resource "aws_lb_target_group" "balancer_tg" {
  ### Target Group ###
  name     = "balancer-tg"
  port     = 11000
  protocol = "TCP"
  vpc_id   = "vpc-07cf417c"
}


resource "aws_lb_target_group_attachment" "balancer_tg" {
  ### Target Group Attachment ###
  target_group_arn = "${aws_lb_target_group.balancer_tg.arn}"
  target_id        = "${aws_instance.web_a.id}"
  port             = 11000
}


resource "aws_lb_listener" "balancer_lis" {
  ### Load Balancer Listener ###
  load_balancer_arn = "${aws_lb.balancer.arn}"
  port              = "11000"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.balancer_tg.arn}"
    type             = "forward"
  }
}