data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/counter.py"
  output_path = "${path.module}/src/counter.zip"
}

resource "aws_lambda_function" "counter" {
  function_name    = var.function_name
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "counter.handler"
  runtime          = "python3.12"
  role             = var.lab_role_arn
  timeout          = 10

  environment {
    variables = { TABLE_NAME = var.table_name }
  }

  tags = { Environment = var.environment }
}

# ── Staging / Produzione reale (non Learner Lab) ─────────
# Decommentare e rimuovere lab_role_arn dalla function quando
# si dispone di un account AWS reale con permessi IAM completi.
#
# resource "aws_iam_role" "lambda_exec" {
#   name = "${var.function_name}-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role_policy" "dynamodb_access" {
#   name = "${var.function_name}-dynamodb"
#   role = aws_iam_role.lambda_exec.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
#       Resource = var.table_arn
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "lambda_basic" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
#
# Nella resource aws_lambda_function sostituire:
#   role = var.lab_role_arn
# con:
#   role = aws_iam_role.lambda_exec.arn
