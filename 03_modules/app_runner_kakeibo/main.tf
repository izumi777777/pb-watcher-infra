resource "aws_apprunner_service" "this" {
  service_name = var.service_name

  source_configuration {
    image_repository {
      image_identifier      = "${var.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"

        # シークレット（Secrets Manager参照用）
        runtime_environment_secrets = var.environment_secrets

        # ★追加：通常の環境変数（S3バケット名など）
        runtime_environment_variables = var.runtime_environment_variables
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

  lifecycle {
    ignore_changes = [
      # シークレット情報の更新を無視（手動運用を保護）
      source_configuration[0].image_repository[0].image_configuration[0].runtime_environment_secrets,
      
      # CI/CD等で外部からタグを更新している場合は、ここも有効にすると勝手に戻らなくなります
      # source_configuration[0].image_repository[0].image_identifier
    ]
  }
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}