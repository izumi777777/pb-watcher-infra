# modules/security_group/variables.tf

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}