# ==================================================================
#  S3 CRR用のIAM 
# ==================================================================
# resource "aws_iam_role" "replication" {
#   name = "s3-replication-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "s3.amazonaws.com" }
#     }]
#   })
# }

# Resource指定の部分を書き換え
# 03_modules/iam/main.tf 内のポリシー部分
# resource "aws_iam_policy" "replication" {
#   name = "s3-replication-policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
#         Effect   = "Allow"
#         # 直接文字列で組み立てることで、S3モジュールの完成を待たなくて良くなる
#         Resource = ["arn:aws:s3:::${var.bucket_name}"] 
#       },
#       {
#         Action   = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
#         Effect   = "Allow"
#         Resource = ["arn:aws:s3:::${var.bucket_name}/*"]
#       },
#       {
#         Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
#         Effect   = "Allow"
#         Resource = ["arn:aws:s3:::${var.bucket_name}-replica/*"]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "replication" {
#   role       = aws_iam_role.replication.name
#   policy_arn = aws_iam_policy.replication.arn
# }

# ==================================================================
# 2. App Runner 用の IAM Role
# ==================================================================

# 2-1. アクセスロール（ECRプル & 起動時のシークレット読み取り用）
resource "aws_iam_role" "apprunner_access_role" {
  name = "apprunner-ecr-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# 2-2. インスタンスロール（コンテナ実行中のAWSサービス操作用）
resource "aws_iam_role" "apprunner_instance_role" {
  name = "apprunner-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

# ==================================================================
# 3. EC2 用の IAM Role (作業端末・踏み台用)
# ==================================================================
resource "aws_iam_role" "ec2_role" {
  name = "dev-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# ECRへのログイン・プッシュ権限
resource "aws_iam_role_policy_attachment" "ec2_ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# S3へのアクセス権限（修正版：GetObjectに加え、メタデータ取得等を許可）
resource "aws_iam_role_policy" "ec2_s3_access_policy" {
  name = "dev-ec2-s3-access-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListSpecificBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = ["arn:aws:s3:::*"]
      },
      {
        Sid    = "AllowGetObjectsInSpecificFolder"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListMultipartUploadParts"
        ]
        Resource = ["arn:aws:s3:::*/*"]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "dev-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
