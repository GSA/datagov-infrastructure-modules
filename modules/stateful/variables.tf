variable "ami_id" {
  description = "Id of the AMI to use for instances."
}

variable "associate_public_ip_address" {
  description = "Whether or not a public IP address should be associated with this instance."
  default     = false
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to create EBS volumes in."
}

variable "bastion_host" {
  description = "Host/ip for the jumpbox/bastion host to connect to for provisioning."
  default     = "" # unset
}

variable "dns_zone" {
  description = "DNS zone to create hostname records."
}

variable "ebs_size" {
  default = 10
}

variable "ebs_type" {
  default = "gp2"
}

variable "instance_count" {
  description = "Number of stateful EC2 instances to create."
  default     = 1
}

variable "instance_name_format" {
  description = "Format string specifying how to create instance names. These will be interpolated with the instance count."
  default     = "stateful%dtf"
}

variable "instance_type" {
  description = "EC2 instance type."
  default     = "t2.micro"
}

variable "ansible_group" {
  description = "Name of the ansible group to tag web instances with."
}

variable "iam_instance_profile" {
  description = "The IAM instance profile name to pass to the stateful EC2 instances."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Map of key/value pairs describing tags to create for instances"
  default     = {}
}

variable "key_name" {
}

variable "env" {
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups to assign to instances."
  default     = []
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets to assign instances to."
}

variable "vpc_id" {
  description = "Id of the VPC to create resources in."
}

