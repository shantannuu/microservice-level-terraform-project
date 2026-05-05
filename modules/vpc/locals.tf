locals {
  common_tags = {
    Environment = var.env
    Project     = "netflix-style-infra"
    ManagedBy   = "terraform"
  }
}