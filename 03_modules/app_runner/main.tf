resource "aws_apprunner_service" "this" {
  service_name = var.service_name

  source_configuration {
    image_repository {
      image_identifier      = "${var.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"

        runtime_environment_secrets = {
         "AZURE_TENANT_ID"              = "${var.secret_arn}:AZURE_TENANT_ID::"
          "AZURE_CLIENT_ID"              = "${var.secret_arn}:AZURE_CLIENT_ID::"
          "AZURE_CLIENT_SECRET"          = "${var.secret_arn}:AZURE_CLIENT_SECRET::"
          "AZURE_PROJECT_ENDPOINT"       = "${var.secret_arn}:AZURE_PROJECT_ENDPOINT::"
          "AGENT_ID"                     = "${var.secret_arn}:AGENT_ID::"
          "FIREBASE_API_KEY"             = "${var.secret_arn}:FIREBASE_API_KEY::"
          "FIREBASE_AUTH_DOMAIN"         = "${var.secret_arn}:FIREBASE_AUTH_DOMAIN::"
          "FIREBASE_PROJECT_ID"          = "${var.secret_arn}:FIREBASE_PROJECT_ID::"
          "FIREBASE_STORAGE_BUCKET"      = "${var.secret_arn}:FIREBASE_STORAGE_BUCKET::"
          "FIREBASE_MESSAGING_SENDER_ID" = "${var.secret_arn}:FIREBASE_MESSAGING_SENDER_ID::"
          "FIREBASE_APP_ID"              = "${var.secret_arn}:FIREBASE_APP_ID::"
          "LINE_CHANNEL_ACCESS_TOKEN"    = "${var.secret_arn}:LINE_CHANNEL_ACCESS_TOKEN::"
          "APP_ID"                       = "${var.secret_arn}:APP_ID::"
          # エラー箇所: 末尾を :: に合わせる
          "LINE_CHANNEL_SECRET"          = "${var.secret_arn}:LINE_CHANNEL_SECRET::"
        }
      }
    }
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
    auto_deployments_enabled = true
  }

  # インスタンスロールの設定を明示的に追加
  instance_configuration {
    instance_role_arn = var.instance_role_arn
    cpu               = "1024"
    memory            = "2048"
  }
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}
