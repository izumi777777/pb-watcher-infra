variable "bucket_name" {
  description = "S3バケット名"
  type        = string
}

variable "apprunner_instance_role_name" {
  description = "App Runnerインスタンスロール名（権限付与用）"
  type        = string
}