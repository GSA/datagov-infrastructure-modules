variable "aws_region" {
  description = "AWS Region to create resources in."
  default     = "us-east-1"
}

variable "name" {
  description = "Name slug to use as a prefix or name for resources."
  type        = "string"
}

variable "env" {
  description = "Name of the environment for tagging and name prefixes of resources."
  type        = "string"
}

variable "key_name" {
  description = "SSH key pair name to configure this instance for access."
}

variable "ami_id" {
  description = "AMI Id to use for EC2 web instances."
}

variable "instance_count" {
  description = "Number of EC2 web instances to create."
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for web instances."
  default     = "t2.micro"
}

variable "ansible_group" {
  description = "Name of the ansible group to tag web instances with."
}

variable "dns_zone_name" {
  description = "The DNS zone in Route 53 to create DNS records under."
  default     = "datagov.us"
}

variable "lb_target_groups" {
  type        = "list"
  description = "Target group to attach to the load balancer."

  # example
  # lb_target_groups = [{
  #   name              = "${var.env}-${var.name}"
  #   backend_protocol  = "HTTPS"
  #   backend_port      = "443"
  #   health_check_path = "/"
  # }]
}

variable "public_subnets" {
  type        = "list"
  description = "List of public subnets to attach load balancers to."
}

variable "private_subnets" {
  type        = "list"
  description = "List of private subnets to attach instances to."
}

variable "security_groups" {
  type        = "list"
  description = "Additional security groups to attach to instances."
  default     = []
}

variable "vpc_id" {}