variable "allow_security_groups" {
  type        = list(string)
  description = "List of security group Ids allowed to access redis"
}

variable "auth_token" {
  type        = string
  description = "The auth token (password) to configure for Redis."
}

variable "enable" {
  type        = bool
  description = "When enabled, provision a Redis ElastiCache instance."
  default     = false
}

variable "env" {
  type        = string
  description = "Name of the environment for generating Ids and unique names for Redis and associated resources."
}

variable "name" {
  type        = string
  description = "Name to use for generating Ids and unique names for Redis and associated resources."
}

variable "node_type" {
  description = "ElastiCache node type to provision."
  default     = "cache.t3.small"
}

variable "port" {
  description = "Port Redis should listen on."
  default     = 6379
}

variable "subnets" {
  description = "List of subnets to associate with the elasticache cluster."
  type        = list(string)
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit for the elasticache cluster."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Id of the VPC where Redis should be provisioned."
}
