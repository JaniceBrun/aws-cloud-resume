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
