# output "lambda_arn" {
#   value = aws_lambda_function.this.arn
# }

# output "layer_arn" {
#   value = aws_lambda_layer_version.this.arn
# }

output "lambda_arn" {
  value = aws_lambda_function.rotation.arn
}
