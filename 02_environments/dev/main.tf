# =================================================================== 
#「どんなリソース（VPC、EC2など）を作るか」という構成の本体。 
# ===================================================================

# --- ネットワークモジュールの呼び出し ---
module "vpc" {
  source       = "../../03_modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "my-app"
  env          = "dev"
}

# --- セキュリティグループモジュールの呼び出し ---
module "web_sg" {
  source       = "../../03_modules/security_group"
  vpc_id       = module.vpc.vpc_id # ここでVPCモジュールの出力を渡す
  project_name = "my-app"
  env          = "dev"
}


# ======================================================================
# EC2用IAM
# ======================================================================
# module "iam" {
#   source = "../../03_modules/iam"
#   # secret_arn = module.external_api_secrets.secret_arn
# }

module "iam" {
  source      = "../../03_modules/iam"
  secret_arn  = "arn:aws:secretsmanager:ap-northeast-1:811330714771:secret:example"
  bucket_name = "my-unique-app-tfstate-bucket"
}

# ======================================================================
# EC2モジュールの呼び出し
# ======================================================================
module "my_ec2" {
  source            = "../../03_modules/ec2"
  ami_id            = "ami-09d28faae2e9e7138"
  instance_type     = "t3.micro"
  subnet_id         = module.vpc.public_subnet_1a_id
  security_group_id = module.web_sg.sg_id
  project_name      = "my-app"
  env               = "dev"

  # 新規作成したインスタンスプロファイルを既存のEC2に紐付け
  iam_instance_profile = module.iam.ec2_instance_profile_name

}

# =========================================================================
# ECR Repository (App Runner 用のイメージを格納)
# =========================================================================
module "app_ecr" {
  source          = "../../03_modules/ecr"
  repository_name = "dev-myapp-app-repo"

  # 必要に応じてオプションを変更可能
  untagged_image_count = 3
}


# ============================================================
# Secrets Managerアクセス権限（インラインポリシーとして追加）
# ============================================================
resource "aws_iam_role_policy" "apprunner_secrets_policy" {
  name = "apprunner-secrets-access-policy"
  role = module.iam.apprunner_access_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = "*" # 本番環境では特定のARNに絞ることを推奨
    }]
  })
}

# ========================================================================
# シークレットの作成
# =========================================================================
module "external_api_secrets" {
  source      = "../../03_modules/secrets_manager"
  secret_name = "dev/myapp/external-api-keys"
  description = "External API Keys for App Runner"

  # ローテーション不要な場合は null または適切な値を設定
  rotation_days       = 30
  rotation_lambda_arn = null

  # 旧 env_values から initial_secret_values に変更
  initial_secret_values = {
    AZURE_TENANT_ID        = "REPLACE_ME"
    AZURE_CLIENT_ID        = "REPLACE_ME"
    AZURE_CLIENT_SECRET    = "REPLACE_ME"
    AZURE_PROJECT_ENDPOINT = "https://your-project.azure.com"
    AGENT_ID               = "REPLACE_ME"
    GEMINI_API_KEY         = "REPLACE_ME"

    # --- 追加: Firebase フロントエンド用キー ---
    FIREBASE_API_KEY             = "REPLACE_ME"
    FIREBASE_AUTH_DOMAIN         = "pb-watcher-app.firebaseapp.com"
    FIREBASE_PROJECT_ID          = "pb-watcher-app"
    FIREBASE_STORAGE_BUCKET      = "pb-watcher-app.firebasestorage.app"
    FIREBASE_MESSAGING_SENDER_ID = "400651520598"
    FIREBASE_APP_ID              = "1:400651520598:web:99f06bb3e2a74c577589f7"
    FIREBASE_SERVICE_ACCOUNT_JSON = "dummy"
    
    # LINEやApp IDなどバックエンド用
    LINE_CHANNEL_ACCESS_TOKEN    = "REPLACE_ME"
    APP_ID                       = "pb-stock-monitor-pro"
  }
}

# エラー解消の鍵: Access Role と Instance Role の両方に権限を付与する
resource "aws_iam_role_policy" "apprunner_combined_secrets_policy" {
  for_each = toset([
    module.iam.apprunner_access_role_name,
    module.iam.apprunner_instance_role_name
  ])

  name = "apprunner-secrets-policy-${each.key}"
  role = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = [module.external_api_secrets.secret_arn]
      },
      {
        # KMSで暗号化されている場合に備え、復号権限も付与（リソースは適切なKMS ARNが望ましいが一旦*）
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = ["*"]
      }
    ]
  })
}

# ========================================================================
#  App Runnerモジュールの呼び出し 
# ========================================================================
# module "app_runner" {
#   source          = "../../03_modules/app_runner"
#   service_name    = "dev-myapp-runner"
#   repository_url  = module.app_ecr.repository_url
#   access_role_arn = module.iam.apprunner_access_role_arn
#   # access_role_arn = module.iam.apprunner_access_role_name
#   instance_role_arn = module.iam.apprunner_instance_role_arn
#   secret_arn        = module.external_api_secrets.secret_arn
# }

# output "apprunner_url" {
#   value = module.app_runner.service_url
# }


# ------------------------------------------------------------------
# S3 CRR用設定
# -------------------------------------------------------------------
# 02_environments/dev/main.tf

# 共通で使用するバケット名を定義しておくと管理が楽です
# locals {
#   target_bucket_name = "izumi-terraform-crr-test-bucket"
# }

# ---------------------------
# IAM（CRR用ロール）
# ---------------------------
# module "iam_replication" {
#   source = "../../03_modules/iam"
#   bucket_name = "my-source-bucket-tokyo"
# }

# ---------------------------
# S3 CRR
# ---------------------------
# module "s3_crr" {
#   source = "../../03_modules/s3"

#   providers = {
#     aws         = aws
#     aws.replica = aws.replica
#   }

#   replication_role_arn = module.iam_replication.replication_role_arn

#   replications = {
#     main = {
#       source_bucket = "my-source-bucket-tokyo"
#       dest_bucket   = "my-source-bucket-tokyo-replica"
#     }
#   }
# }

# ================================
# IAM Role for Lambda
# ================================
# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda-exec-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }


# ---------------------------
# lambda
# ---------------------------
# module "lambda" {
#   source = "../../03_modules/lambda"

#   function_name = "sample-api"
#   role_arn       = aws_iam_role.lambda_exec.arn
# }


# =========================================================================
# Lambda、シークレットマネージャーローテーション検証
# =========================================================================

# IAM Role
# resource "aws_iam_role" "rotation_role" {
#   name = "dev-rotation-lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Action    = "sts:AssumeRole"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }

# IAM Role作成後、AWS側で使えるようになるまで待つ
# Lambda作成時の "IAM Role is not ready" エラーやハングアップを防ぐため、長めに設定
# resource "time_sleep" "wait_for_iam" {
#   create_duration = "90s"
#   depends_on      = [aws_iam_role.rotation_role]
# }

# Rotation Lambda（先に作る）
# module "rotation_lambda" {
#   source        = "../../03_modules/lambda"
#   function_name = "dev-rotation-function-v2"
#   role_arn      = aws_iam_role.rotation_role.arn

#   # depends_on = [time_sleep.wait_for_iam]
# }

# Secrets Manager
# module "app_secrets" {
#   source = "../../03_modules/secrets_manager"

#   secret_name   = "dev/myapp/database-credentials8"
#   description   = "Database credentials for dev environment"
#   rotation_days = 30
#   # 開発用: 削除時は復旧期間なしで即時削除 (エラー回避のため)
#   # recovery_window_in_days = 0

#   rotation_lambda_arn = module.rotation_lambda.lambda_arn

#   initial_secret_values = {
#     username = "admin"
#     password = "initial-password-123"
#   }

# 重要: Lambda本体と、その実行許可(Permission)が降りるまで Secretモジュール全体を待機させる
#   depends_on = [
#     module.rotation_lambda.lambda_arn,
#     module.rotation_lambda.lambda_permission_id
#   ]

# }

# =========================================================================
# Post-Creation Policy Attachment (循環参照回避)
# =========================================================================

# LambdaとSecretの両方ができた後に、LambdaにSecret操作権限を与える
# resource "aws_iam_role_policy" "rotation_policy" {
#   name = "dev-rotation-policy"
#   role = aws_iam_role.rotation_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret",
#           "secretsmanager:PutSecretValue",
#           "secretsmanager:UpdateSecretVersionStage"
#         ]
#         # 作成された特定のSecretのみに絞る
#         Resource = module.app_secrets.secret_arn
#       },
#       {
#         Effect   = "Allow"
#         Action   = "secretsmanager:GetRandomPassword"
#         Resource = "*"
#       }
#     ]
#   })
# }

