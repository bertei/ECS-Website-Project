## VPC Variables
variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = null
}

## Subnet variables
variable "subnets" {
  description = "Map of subnets"
  type        = any
}

variable "subnet_id" {
  description = "Security group id"
  type = string
  default = null
}

## Security group variables
variable "security_groups" {
  description = "Map of Security groups"
  type = any
  default = {}
}

variable "sg_ingress" {
  description = "Map containing SG's ingress rules"
  type = any
  default = {}
}

variable "sg_egress" {
  description = "Map containing SG's egress rules"
  type = any
  default = {}
}

variable "cert_arn" {
  description = "Hardcoded acm cert arn"
  type = string
  default = ""
}