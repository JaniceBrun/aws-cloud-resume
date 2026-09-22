output "function_arn"  { value = aws_lambda_function.counter.arn }
output "function_name" { value = aws_lambda_function.counter.function_name }
output "invoke_arn"    { value = aws_lambda_function.counter.invoke_arn }
