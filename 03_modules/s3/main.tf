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
