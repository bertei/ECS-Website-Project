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
  default = "arn:aws:acm:us-east-1:378842471989:certificate/58887715-d99d-4773-aef4-a64e502686cd"
}

## Loadbalancer variables
#variable "lb_name" {
#  description = "LB name"
#  type = string
#  default = null
#}

#variable "alb_listeners" {
#  description = "Map containing ALB listeners"
#  type = any
#  default = {}
#}
#
#variable "default_actions" {
#  description = "Map containing default_actions"
#  type = any
#  default = {}
#}