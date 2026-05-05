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
    sg_name = "service-a-sg"
    sg_description = "Security group for service-a"
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
        Service = "service-a"
    }
}

resource "aws_lb_target_group" "service_a" {
  name     = "service-a-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/serviceA/status"
  }
}

resource "aws_lb_target_group" "service_a_green" {
  name     = "service-a-tg-green"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/serviceA/status"
  }
}

resource "aws_lb_listener_rule" "service_a" {
  listener_arn = data.terraform_remote_state.alb.outputs.alb_listener_arn

  priority = 1

  action {
    type             = "forward"
    target_group_arn = local.active_target_group
  }

  condition {
    path_pattern {
      values = ["/serviceA/*"]
    }
  }
}

# module "asg" {
#   source = "../../../../modules/autoscaling"

#   name              = "service-a"
#   ami               = "ami-07f919f92632ae971"   # use valid AMI
#   instance_type     = "t3.micro"

#   subnets           = data.terraform_remote_state.vpc.outputs.private_subnet_ids
#   security_group_id = module.service_sg.sg_id

#   target_group_arns = []

#   desired_capacity  = 0
#   min_size          = 0
#   max_size          = 0

#   user_data_file    = "../../../../live/dev/compute/service-a/serviceA.sh"
# }

module "asg_green" {
  source = "../../../../modules/autoscaling"

  name              = "service-a-green"
  ami               = "ami-07f919f92632ae971"   # use valid AMI
  instance_type     = "t3.micro"

  subnets           = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  security_group_id = module.service_sg.sg_id

  target_group_arns = [aws_lb_target_group.service_a_green.arn]

  desired_capacity  = 2
  min_size          = 1
  max_size          = 4

  user_data_file    = "../../../../live/dev/compute/service-a/serviceA.sh"
}