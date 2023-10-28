output "subnet_id" {
  value = [ for subnet in aws_subnet.main : subnet.id ]
}

output "sg_id" {
  value = [ for sg in aws_security_group.main : sg.id ]
}

output "alb_tg_arn" {
  value = aws_alb_target_group.main.arn
}