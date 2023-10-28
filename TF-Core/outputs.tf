#output "ecr_repo_url" {
#  value = module.ecr.ecr_repo_url
#}

output "subnet_ids" {
  value = module.network-services.subnet_id
}

output "sg_ids" {
  value = module.network-services.sg_id
}

output "alb_tg_arns" {
  value = module.network-services.alb_tg_arn
}