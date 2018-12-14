output "web_alb_dns" {
  value = "${aws_alb.web_alb.dns_name}"
}

output "jumpbox_dns" {
  value = "${aws_instance.catalog-jumpbox.public_dns}"
}

output "dashboard_web_dns" {
  value = "${module.dashboard_web_alb.dns_name}"
}
