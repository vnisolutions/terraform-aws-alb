output "target_group_arn" {
  value = [aws_lb_target_group.alb-tg.arn]
}

output "sg_alb" {
  value = [aws_security_group.sg-alb.id]
}

output "alb_id" {
  value       = try(aws_lb.alb.id, "")
}