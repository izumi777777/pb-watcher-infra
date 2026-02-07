# =================================================================== 
#「どんなリソース（VPC、EC2など）を作るか」という構成の本体。 
# ===================================================================
# 1.tfstate保存用バケット
resource "aws_s3_bucket" "terraform_state" {
    bucket = "my-unique-app-tfstate-bucket"
  
    # 誤削除防止
    lifecycle {
      prevent_destroy = true
    }
}

# 2.バージョニング有効化
resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}

# 3.サーバーサイド暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

# 4.公開アクセスのブロック (セキュリティのベストプラクティス)
resource "aws_s3_bucket_public_access_block" "name" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# 5.ロック制御用DynamoDBテーブル
resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-state-lock"
    billing_mode = "PAY_PER_REQUEST" # 低コストな従量課金
    hash_key = "LockID" # この名前は固定

    # 削除保護を有効化
    deletion_protection_enabled = true
    
    attribute {
      name = "LockID"
      type = "S"
    }
}

terraform {
  backend "s3" {
    bucket         = "my-unique-app-tfstate-bucket" # 先ほど作成したバケット名
    key            = "management/tfstate/terraform.tfstate"
    region         = "ap-northeast-1"
    profile        = "my-project" # これを追加
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
