variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type = string
  default = null
}

variable "task_name" {
  description = "ECS Task name"
  type = string
  default = null
}

variable "image" {
  description = "ECS Task container image"
  type = string
  default = null
}

variable "container_name" {
  description = "ECS container name"
  type = string
  default = null
}

variable "service_name" {
  description = "ECS service name"
  type = string
  default = null
}

variable "subnet_id" {
  description = "Subnet id needed for ECS Service networking"
  type = any
  default = null
}

variable "security_group_id" {
  description = "Security group id needed for ECS Service networking"
  type = any
  default = null
}

variable "tg_arn" {
  description = "Target group arn"
  type = string
  default = null
}
