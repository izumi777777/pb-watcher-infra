terraform {
  required_version = "~> 1.0" # Terraform自体のバージョンを固定（推奨）

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # AWSプロバイダーのバージョンを固定（推奨）
    }
  }
}