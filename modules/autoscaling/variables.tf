variable "name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_group_arns" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "user_data_file" {
  type = string
}