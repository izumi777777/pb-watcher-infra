# リソース定義のみを記述（変数は variables.tf、出力は outputs.tf に任せる）

resource "aws_secretsmanager_secret" "app_env" {
  name                    = var.secret_name
  description             = var.description
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "app_env" {
  secret_id     = aws_secretsmanager_secret.app_env.id
  secret_string = jsonencode(var.initial_secret_values)

  # 手動で更新した値をTerraformが上書きするのを防ぐ
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ローテーション設定（値が渡されている場合のみ有効化）
resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.rotation_lambda_arn != null ? 1 : 0

  secret_id           = aws_secretsmanager_secret.app_env.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}