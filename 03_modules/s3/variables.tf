# variable "replications" {
#   description = "CRRの送信元・送信先バケットのペア定義"
#   type = map(object({
#     source_bucket = string
#     dest_bucket   = string
#   }))
# }

# variable "replication_role_arn" {
#   type = string
# }

variable "bucket_name" {
  description = "S3バケット名"
  type        = string
}

variable "apprunner_instance_role_name" {
  description = "App Runnerインスタンスロール名（権限付与用）"
  type        = string
}
