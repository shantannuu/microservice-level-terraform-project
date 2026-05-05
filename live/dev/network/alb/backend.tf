terraform {
  backend "s3" {
    bucket         = "tf-state-2026-shantanu"
    key            = "env/dev/network/alb/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}