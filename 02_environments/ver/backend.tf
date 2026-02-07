terraform {
  backend "s3" {
    bucket         = "my-unique-app-tfstate-bucket" # managementで作成したバケット名
    key            = "ver/terraform.tfstate"       # 管理しやすいパス
    region         = "ap-northeast-1"
    profile        = "my-project"                  # 使用しているプロファイル
    dynamodb_table = "terraform-state-lock"        # ロック用テーブル名
    encrypt        = true
  }
}