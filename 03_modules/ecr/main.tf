resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  force_delete = true # 開発環境用：リポジトリ削除時にイメージがあっても削除する
}

# ライフサイクルポリシー（古いイメージを自動削除）
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.untagged_image_count} untagged images"
      selection = {
        tagStatus     = "untagged"
        countType     = "imageCountMoreThan"
        countNumber   = var.untagged_image_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}
