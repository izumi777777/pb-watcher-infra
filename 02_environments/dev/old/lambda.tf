# ================================
# Lambda Layer
# ================================
resource "aws_lambda_layer_version" "this" {
  layer_name = "${var.function_name}-layer"

  filename   = "${path.module}/layer.zip"
  compatible_runtimes = [var.runtime]

  source_code_hash = filebase64sha256("${path.module}/layer.zip")
}

# ================================
# Lambda Function
# ================================
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  layers = [
    aws_lambda_layer_version.this.arn
  ]
}
