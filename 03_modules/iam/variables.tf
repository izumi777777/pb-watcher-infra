variable "bucket_name" {
  type = string
}

variable "secret_arn" {
  description = "ARN of Secrets Manager secret for App Runner"
  type        = string
}
