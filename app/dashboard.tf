# dashboard-web infrastructure
# TODO this should be moved to its own module
data "aws_ami" "dashboard_web" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "dashboard_web_alb_sg" {
  name        = "${var.env}-dashboard-web-alb-sg-tf"
  description = "ALB security group for dashboard-web"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "dashboard_web_alb" {
  source                   = "terraform-aws-modules/alb/aws"
  load_balancer_name       = "dashboard-web-alb"
  security_groups          = ["${aws_security_group.dashboard_web_alb_sg.id}"]
  subnets                  = ["${data.terraform_remote_state.vpc.private_subnets}"]
  tags                     = "${map("Environment", var.env)}"
  vpc_id                   = "${data.terraform_remote_state.vpc.vpc_id}"
  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "dashboard-web", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "1"
  logging_enabled          = false
}

resource "aws_lb_target_group_attachment" "dashboard_web" {
  count            = "${var.dashboard_web_instance_count}"
  target_group_arn = "${module.dashboard_web_alb.target_group_arns[0]}"
  target_id        = "${element(aws_instance.dashboard_web.*.id, count.index)}"
  port             = 80
}

resource "aws_instance" "dashboard_web" {
  count                  = "${var.dashboard_web_instance_count}"
  ami                    = "${data.aws_ami.dashboard_web.id}"
  instance_type          = "${var.dashboard_web_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}", "${aws_security_group.ssh-sg.id}"]

  subnet_id = "${element(data.terraform_remote_state.vpc.public_subnets, count.index)}"
  key_name  = "${var.key_name}"

  #associate_public_ip_address = true
  user_data = "${data.template_file.web_user_data.rendered}"

  tags {
    Name  = "dashboard-web${count.index + 1}tf"
    env   = "${var.env}"
    group = "dashboard-web"
  }

  lifecycle {
    create_before_destroy = true
  }
}
