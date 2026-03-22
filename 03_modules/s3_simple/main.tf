# S3バケット本体
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}

# バージョニング
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 1. パブリックアクセスブロックを解除する
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 2. バケットポリシーを適用する
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.this.id

  # ★重要: ブロック解除が終わるまで待機させる
  depends_on = [aws_s3_bucket_public_access_block.this]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      },
    ]
  })
}

# App Runnerからの書き込み権限（インラインポリシーをロールにアタッチ）
resource "aws_iam_role_policy" "upload_policy" {
  name = "${var.bucket_name}-upload-policy"
  role = var.apprunner_instance_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:PutObjectAcl"]
      Resource = "${aws_s3_bucket.this.arn}/*"
    }]
  })
}