variable "secret_name" {
  description = "Secrets Managerのリソース名"
  type        = string
}

variable "description" {
  description = "シークレットの説明文"
  type        = string
  default     = ""
}

variable "initial_secret_values" {
  description = "シークレットに保存する初期値（JSON形式に変換されるマップ）"
  type        = map(string)
}

variable "rotation_days" {
  description = "自動ローテーションの周期（日）"
  type        = number
  default     = 30
}

variable "rotation_lambda_arn" {
  description = "ローテーションを実行するLambdaのARN（nullの場合はローテーション無効）"
  type        = string
  default     = null
}