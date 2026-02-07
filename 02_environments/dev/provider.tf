# ============================================================================================
# 「どのクラウド（AWS、Google Cloudなど）の、どの認証情報を使って繋ぐか」という接続の設定。
# ============================================================================================

terraform {
  required_version = "~> 1.0" # Terraform自体のバージョンを固定（推奨）

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # AWSプロバイダーのバージョンを固定（推奨）
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "my-project"
}

# レプリケーション先リージョン (例: オレゴン)
provider "aws" {
  alias   = "replica"
  region  = "us-west-2"
  profile = "my-project"
}