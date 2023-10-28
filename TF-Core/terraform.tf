#Statefile managed manually.
terraform {
  backend "s3" {
    bucket = "ecs-project"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Test"
      Name        = "Example"
      Managed-by  = "Terraform"
    }
  }
}

module "network-services" {
  source = "../TF-Modules//vpc"

  #VPC Parameters definition
  vpc_cidr_block = "10.0.0.0/24"

  #Subnet Params definition
  subnets = {
    subnet-1 = {
      az   = "us-east-1a"
      cidr = "10.0.0.0/28"
    }
    subnet-2 = {
      az   = "us-east-1b"
      cidr = "10.0.0.16/28"
    }
  }

  ##Security group Params definition
  security_groups = {
    ecs-lb-sg = {
      description = "ECS Loadbalancer security group"
    }
  }
  sg_ingress = {
    rule-1 = {
      description = "Allow HTTP requests"
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    rule-2 = {
      description = "Allow HTTPS requests"
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }    
  }
  sg_egress = {
    rule-1 = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

#module "ecr" {
#  source = "../TF-Modules//ecr"
#
#  ecr_repo_name = "ecs-website-images"
#  mutability    = true 
#}
#
#module "ecs" {
#  source = "../TF-Modules//ecs"
#
#  ##ECS Cluster params. definition
#  ecs_cluster_name = "ecs-fargate-cluster"
#
#  ##ECS Task params. definition
#  task_name       = "ecs-fargate-task"
#  image           = module.ecr.ecr_repo_url
#  container_name  = "bernatei-website"
#
#  ##ECS Service definition params.
#  service_name      = "ecs-fargate-service"
#  subnet_id         = module.network-services.subnet_id
#  security_group_id = module.network-services.sg_id
#  tg_arn            = module.network-services.alb_tg_arn
#}