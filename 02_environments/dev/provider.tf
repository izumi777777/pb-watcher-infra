# ============================================================================================
# 「どのクラウド（AWS、Google Cloudなど）の、どの認証情報を使って繋ぐか」という接続の設定。
# ============================================================================================

terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "my-project"
}

# レプリケーション先リージョン (一時的な架け橋として1つだけ残す)
provider "aws" {
  alias   = "replica"
  region  = "us-west-2"
  profile = "my-project" # メインのプロバイダーと合わせるのが無難です
}

# ↓ 下記の重複していたブロックは削除しました
# provider "aws" {
#   alias  = "replica"
#   region = "us-west-2"
# }