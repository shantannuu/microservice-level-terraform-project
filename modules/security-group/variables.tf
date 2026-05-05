variable "sg_name" {
  description = "Security group name"
  type        = string
}

variable "sg_description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    sg_ids      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "sg_tags" {
  description = "Security group tags"
  type        = map(string)
}