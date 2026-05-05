terraform {
  backend "s3" {
    bucket         = "tf-state-2026-shantanu"
    key            = "env/dev/compute/service-a/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}