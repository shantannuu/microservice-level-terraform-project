resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.security_group_id]

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "welcome to the website"
      status_code = "200"
    }
  }
}
