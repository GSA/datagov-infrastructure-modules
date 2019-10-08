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

module "wordpress" {
  source = "../modules/wordpress"

  database_subnet_group = "${data.terraform_remote_state.vpc.database_subnet_group}"
  db_password           = "${var.db_password}"
  bastion_host          = "${data.terraform_remote_state.jumpbox.jumpbox_dns}"
  dns_zone_public       = "${data.terraform_remote_state.vpc.dns_zone_public}"
  dns_zone_private      = "${data.terraform_remote_state.vpc.dns_zone_private}"
  env                   = "${var.env}"
  instance_count        = "${var.web_instance_count}"
  key_name              = "${var.key_name}"
  subnets_private       = "${data.terraform_remote_state.vpc.private_subnets}"
  subnets_public        = "${data.terraform_remote_state.vpc.public_subnets}"
  security_groups       = ["${data.terraform_remote_state.jumpbox.security_group_id}"]
  vpc_id                = "${data.terraform_remote_state.vpc.vpc_id}"
}
