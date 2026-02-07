variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

# 既存のEC2に後からアタッチできるように追加
variable "iam_instance_profile" {
  type    = string
  default = null
}