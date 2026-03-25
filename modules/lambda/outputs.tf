output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_alias_name" {
  value = "$LATEST"
}

output "lambda_alias_arn" {
  value = aws_lambda_function.this.invoke_arn
}