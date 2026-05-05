locals {
  active_target_group = ( var.active_tg == "blue" ? aws_lb_target_group.service_a.arn : aws_lb_target_group.service_a_green.arn )
}