# Generated API GW endpoint URL that can be used to access the application running on a private ECS Fargate cluster.
output "apigw_endpoint" {
  value = aws_apigatewayv2_api.apigw_http_endpoint.api_endpoint
    description = "API Gateway Endpoint"
}

output "invoke_url" {
  description = "The URL to invoke the API pointing to the stage"
  value       = try(aws_apigatewayv2_stage.apigw_stage.invoke_url, "")
}