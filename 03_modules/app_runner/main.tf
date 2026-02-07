resource "aws_apprunner_service" "this" {
  service_name = var.service_name

  source_configuration {
    image_repository {
      image_identifier      = "${var.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = "5000"

        runtime_environment_secrets = {
          "AZURE_TENANT_ID"        = "${var.secret_arn}:AZURE_TENANT_ID::"
          "AZURE_CLIENT_ID"        = "${var.secret_arn}:AZURE_CLIENT_ID::"
          "AZURE_CLIENT_SECRET"    = "${var.secret_arn}:AZURE_CLIENT_SECRET::"
          "AZURE_PROJECT_ENDPOINT" = "${var.secret_arn}:AZURE_PROJECT_ENDPOINT::"
          "AGENT_ID"               = "${var.secret_arn}:AGENT_ID::"
          "GEMINI_API_KEY"         = "${var.secret_arn}:GEMINI_API_KEY::"
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
