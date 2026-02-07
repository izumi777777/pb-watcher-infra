# S3モジュールに渡すためにロールのARNを排出する
# output "replication_role_arn" {
#   value = aws_iam_role.replication.arn
# }

output "apprunner_access_role_name" {
  value = aws_iam_role.apprunner_access_role.name
}

output "apprunner_access_role_arn" {
  value = aws_iam_role.apprunner_access_role.arn
}

output "apprunner_instance_role_arn" {
  value = aws_iam_role.apprunner_instance_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "apprunner_instance_role_name" {
  value = aws_iam_role.apprunner_instance_role.name
}

