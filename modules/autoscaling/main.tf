resource "aws_launch_template" "this" {
  name_prefix   = var.name
  image_id      = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }

  user_data = filebase64(var.user_data_file)
}

resource "aws_autoscaling_group" "this" {
  name = var.name

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  target_group_arns = var.target_group_arns
  
  health_check_type = "ELB"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name = "CPUUtilizationPolicy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0

  }
}