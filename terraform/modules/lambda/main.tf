data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/counter.py"
  output_path = "${path.module}/src/counter.zip"
}

# ── IAM Role dedicato — solo per prod (use_oac = true) ───
resource "aws_iam_role" "lambda_exec" {
  count = var.use_oac ? 1 : 0
  name  = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "dynamodb_access" {
  count = var.use_oac ? 1 : 0
  name  = "${var.function_name}-dynamodb"
  role  = aws_iam_role.lambda_exec[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
      Resource = var.table_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = var.use_oac ? 1 : 0
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "counter" {
  function_name    = var.function_name
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "counter.handler"
  runtime          = "python3.12"
  role             = var.use_oac ? aws_iam_role.lambda_exec[0].arn : var.lab_role_arn
  timeout          = 10

  environment {
    variables = { TABLE_NAME = var.table_name }
  }

  tags = { Environment = var.environment }
}
