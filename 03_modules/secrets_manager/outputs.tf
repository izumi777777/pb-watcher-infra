# --- 追加: 他のモジュールから参照するための出力 ---
output "secret_arn" {
  description = "作成されたシークレットのARN"
  value       = aws_secretsmanager_secret.app_env.arn
}