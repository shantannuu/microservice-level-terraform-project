data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket         = "tf-state-2026-shantanu"
        key            = "env/dev/network/vpc/terraform.tfstate"
        region         = "ap-south-1"
        dynamodb_table = "tfstate-locks"
        encrypt        = true
    }
}

data "terraform_remote_state" "alb" {
    backend = "s3"
    config = {
        bucket         = "tf-state-2026-shantanu"
        key            = "env/dev/network/alb/terraform.tfstate"
        region         = "ap-south-1"
        dynamodb_table = "tfstate-locks"
        encrypt        = true
    }
}

module "service_sg" {
    source = "../../../../modules/security-group"
    sg_name = "service-b-sg"
    sg_description = "Security group for service-b"
    env = "dev"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

    ingress_rules = [
        {
            from_port   = 8080
            to_port     = 8080
            protocol    = "tcp"
            sg_ids      = [data.terraform_remote_state.alb.outputs.sg_id]
        }
    ]

    sg_tags = {
        Service = "service-b"
    }
}

resource "aws_lb_target_group" "service_b" {
  name     = "service-b-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/serviceB/status"
  }
}

resource "aws_lb_listener_rule" "service_b" {
  listener_arn = data.terraform_remote_state.alb.outputs.alb_listener_arn

  priority = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_b.arn 
  }

  condition {
    path_pattern {
      values = ["/serviceB/*"]
    }
  }
}

module "asg" {
  source = "../../../../modules/autoscaling"

  name              = "service-b"
  ami               = "ami-07f919f92632ae971"   # use valid AMI
  instance_type     = "t3.micro"

  subnets           = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  security_group_id = module.service_sg.sg_id

  target_group_arns = [aws_lb_target_group.service_b.arn]

  desired_capacity  = 2
  min_size          = 1
  max_size          = 4

  user_data_file    = "../../../../live/dev/compute/service-b/serviceB.sh"
}