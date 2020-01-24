data "aws_ami" "cco_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ckan-cloud-operator-*"]
  }

  owners = ["561987031915"]  # datopian
}

resource "aws_security_group" "ssh" {
  name        = "${var.env}-cco-mgmt"
  description = "${var.env} CCO management server"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO all the hosts should be able to talk to ubuntu 80/443 for updates. Not
  # sure where that security group should live. Maybe in VPC as a default sg?
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source = "../vpc"

  azs                = ["us-east-1c", "us-east-1d"]
  env                = "${var.env}"
  single_nat_gateway = true
  vpc_name           = "ckan-cloud-${var.env}"
}

module "management" {
  source = "../stateless"

  ami_id = "${data.aws_ami.cco_ami.id}"
  vpc_id = "${module.vpc.vpc_id}"
  ansible_group = "cco"
  dns_zone = "ckan-cloud-dev.datagov.us"
  env = "${var.env}"
  key_name = "${var.key_name}"
  subnets = ["${module.vpc.public_subnets}"]
}

resource "aws_iam_user" "management" {
  name          = "ckan-cloud-management-${var.env}"
  force_destroy = true
}

# TODO these are too broad

resource "aws_iam_policy" "eks_rw" {
  name = "AllowEKSFullAccess-${var.env}"
  description = "Read/write access to EKS"

  # TODO limit access to what is necessary
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "*"
        }
    ]
}
EOF
}

# TODO is this used?
resource "aws_iam_user_policy_attachment" "management_asg_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# TODO is this used?
resource "aws_iam_user_policy_attachment" "management_cf_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_user_policy_attachment" "management_dns_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_user_policy_attachment" "management_ec2_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "management_efs_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_user_policy_attachment" "management_eks_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "${aws_iam_policy.eks_rw.arn}"
}

# TODO is this used?
resource "aws_iam_user_policy_attachment" "management_iam_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user_policy_attachment" "management_rds_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_user_policy_attachment" "management_s3_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# TODO is this used?
resource "aws_iam_user_policy_attachment" "management_vpc_rw" {
  user       = "${aws_iam_user.management.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
