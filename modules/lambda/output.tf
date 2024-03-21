output "lambda_invoke_arn" {
  value = aws_lambda_function.authorizer_lambda.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.authorizer_lambda.function_name
}