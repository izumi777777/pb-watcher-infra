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

# 既存モジュールとの違い: シークレットを外から自由に渡せる
variable "environment_secrets" {
  description = "コンテナに渡すシークレットのマップ（キー名 -> Secrets Manager ARNパス）"
  type        = map(string)
  default     = {}
}

# 03_modules/app_runner_kakeibo/variables.tf に追記

variable "environment_variables" {
  description = "コンテナに渡す通常の環境変数のマップ"
  type        = map(string)
  default     = {}
}