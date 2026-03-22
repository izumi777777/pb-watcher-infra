# =========================================================================
# Threads画像用 S3バケット (レプリケーションなし・公開読み取り許可)
# =========================================================================
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

# パブリックアクセスのブロック解除
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 公開読み取りポリシー（Meta API用）
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
    }]
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



# ================================
# レプリケーション先（オレゴン）
# ================================
resource "aws_s3_bucket" "destination" {
  for_each = var.replications

  provider      = aws.replica
  bucket        = each.value.dest_bucket
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "destination" {
  for_each = var.replications

  provider = aws.replica
  bucket   = aws_s3_bucket.destination[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ================================
# レプリケーション元（東京）
# ================================
resource "aws_s3_bucket" "source" {
  for_each = var.replications

  bucket        = each.value.source_bucket
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "source" {
  for_each = var.replications

  bucket = aws_s3_bucket.source[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ================================
# CRR 設定
# ================================
resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = var.replications

   depends_on = [
    aws_s3_bucket_versioning.source,
    aws_s3_bucket_versioning.destination
  ]

  role   = var.replication_role_arn
  bucket = aws_s3_bucket.source[each.key].id

  rule {
    id     = "replicate-all-${each.key}"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination[each.key].arn
      storage_class = "STANDARD"
    }
  }
}
