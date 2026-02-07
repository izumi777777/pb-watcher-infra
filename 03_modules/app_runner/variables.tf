variable "secret_arn" {
  description = "Secrets ManagerのARN"
  type        = string
}

variable "service_name" {
  description = "App Runnerサービス名"
  type        = string
}

variable "repository_url" {
  description = "ECRリポジトリのURL"
  type        = string
}

variable "access_role_arn" {
  description = "ECRプル等に使用するアクセスロールのARN"
  type        = string
}

variable "instance_role_arn" {
  description = "コンテナ実行時に使用するインスタンスロールのARN"
  type        = string
}

variable "image_tag" {
  description = "デプロイするイメージのタグ"
  type        = string
  default     = "latest"
}