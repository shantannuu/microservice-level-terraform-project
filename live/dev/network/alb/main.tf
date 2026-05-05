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

module "service_sg" {
    source = "../../../../modules/security-group"
    sg_name = "service-alb-sg"
    sg_description = "Security group for service-alb"
    env = "dev"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

    ingress_rules = [
        {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            ipv6_cidr_blocks = ["::/0"]
        }
    ]

    sg_tags = {
        Service = "service-alb"
    }
}

module "alb" {
  source = "../../../../modules/alb"

  name              = "service-alb"
  subnets           = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  security_group_id = module.service_sg.sg_id

}