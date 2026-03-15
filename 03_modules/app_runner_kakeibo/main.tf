resource "aws_apprunner_service" "this" {
  service_name = var.service_name

  source_configuration {
    image_repository {
      image_identifier      = "${var.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"

        # 既存モジュールとの違い: ハードコードせず変数で受け取る
        runtime_environment_secrets = var.environment_secrets
      }
    }
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    instance_role_arn = var.instance_role_arn
    cpu               = "1024"
    memory            = "2048"
  }
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}