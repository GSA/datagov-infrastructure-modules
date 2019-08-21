data "aws_route53_zone" "default" {
  name         = "${var.dns_zone}"
  private_zone = true
}

resource "aws_ebs_volume" "default" {
  count = "${var.instance_count}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  type              = "${var.ebs_type}"
  size              = "${var.ebs_size}"

  tags = "${merge(map("env", var.env), var.tags)}"
}

resource "aws_volume_attachment" "default" {
  device_name = "/dev/xvdh"
  volume_id   = "${aws_ebs_volume.default.id}"
  instance_id = "${aws_instance.default.id}"
}

resource "aws_instance" "default" {
  count = "${var.instance_count}"

  ami                    = "${var.ami_id}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${var.security_groups}"]

  associate_public_ip_address = "${var.associate_public_ip_address}"
  subnet_id                   = "${element(var.subnets, count.index)}"
  key_name                    = "${var.key_name}"

  tags = "${merge(
    map(
      "Name", format(var.instance_name_format, count.index + 1),
      "env", var.env,
      "group", var.ansible_group
    ),
    var.tags)}"
}

# Provision stateful instance only after EBS volumes are attached
resource "null_resource" "default" {
  triggers {
    attachment_ids = "${aws_volume_attachment.default.id}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${aws_instance.default.private_ip}"

    bastion_host = "${var.bastion_host != "" ? var.bastion_host : aws_instance.default.private_ip}"
  }

  provisioner "file" {
    # initialize stateful EBS
    # TODO the path here is very strange, not sure if this is a terragrunt
    # thing, nested module thing, or terraform thing.
    source = "../modules/stateful/bin/initialize-stateful.sh"

    destination = "/tmp/initialize-stateful.sh"
  }

  provisioner "remote-exec" {
    # install Ansible executor dependencies and initialize EBS
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python",
      "chmod +x /tmp/initialize-stateful.sh",
      "sudo /tmp/initialize-stateful.sh",
    ]
  }
}

resource "aws_route53_record" "default" {
  count = "${var.instance_count}"

  name    = "${format(var.instance_name_format, count.index + 1)}"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.default.*.private_dns, count.index)}"]
}
