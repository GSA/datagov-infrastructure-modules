provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "datagov-terraform-state"
    key    = "${var.env}/vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "jumpbox" {
  backend = "s3"

  config {
    bucket = "datagov-terraform-state"
    key    = "${var.env}/jumpbox/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_filter_name}"]
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

data "aws_route53_zone" "public" {
  name = "${data.terraform_remote_state.vpc.dns_zone_public}"
}

resource "aws_security_group" "default" {
  name        = "jenkins-${var.env}-tf"
  description = "Jenkins security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_route53_record" "public" {
  name    = "ci"
  zone_id = "${data.aws_route53_zone.public.zone_id}"

  type    = "A"
  ttl     = "300"
  records = ["${module.jenkins.instance_public_ip}"]
}

module "jenkins" {
  source = "../modules/stateful"

  ami_id                      = "${data.aws_ami.ubuntu.id}"
  ansible_group               = "jenkins"
  associate_public_ip_address = true
  availability_zones          = "${data.terraform_remote_state.vpc.azs}"
  bastion_host                = "${data.terraform_remote_state.jumpbox.jumpbox_dns}"
  dns_zone                    = "${data.terraform_remote_state.vpc.dns_zone_private}"
  ebs_size                    = "${var.ebs_size}"
  env                         = "${var.env}"
  instance_count              = "1"
  instance_name_format        = "jenkins%dtf"
  instance_type               = "t2.medium"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.default.id}", "${data.terraform_remote_state.jumpbox.security_group_id}"]
  subnets                     = "${data.terraform_remote_state.vpc.public_subnets}"
  vpc_id                      = "${data.terraform_remote_state.vpc.vpc_id}"
}
