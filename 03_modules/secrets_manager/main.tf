# variable "secret_name" {
#   type = string
# }

# variable "description" {
#   type    = string
#   default = ""
# }

# variable "initial_secret_values" {
#   type = map(string)
# }

# variable "rotation_lambda_arn" {
#   type = string
# }

# variable "rotation_days" {
#   type = number
# }

# resource "aws_secretsmanager_secret" "this" {
#   name        = var.secret_name
#   description = var.description
# }

# resource "aws_secretsmanager_secret_version" "initial" {
#   secret_id     = aws_secretsmanager_secret.this.id
#   secret_string = jsonencode(var.initial_secret_values)

#   lifecycle {
#     ignore_changes = [secret_string]
#   }
# }

# resource "aws_secretsmanager_secret_rotation" "this" {
#   secret_id           = aws_secretsmanager_secret.this.id
#   rotation_lambda_arn = var.rotation_lambda_arn
   

#   rotation_rules {
#     automatically_after_days = var.rotation_days
#   }
# }

# output "secret_arn" {
#   value = aws_secretsmanager_secret.this.arn
# }
