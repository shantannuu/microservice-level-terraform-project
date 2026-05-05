output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "alb_listener_arn" {
  value = aws_lb_listener.http.arn
}