################################################################################
# VPC Link
################################################################################
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name               = "vpclink_apigw_to_alb"
  security_group_ids = [      
      "${var.lb_engress_id}",
      "${var.lb_ingress_id}"
      ]
  subnet_ids         = var.privates_subnets_id
}

resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = "hackaton-api"
  protocol_type = "HTTP"
}

################################################################################
# Api Gateway
################################################################################

resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.listener_arn

  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  payload_format_version = "1.0"
  depends_on = [aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
  aws_apigatewayv2_api.apigw_http_endpoint]
}

# Set a default stage
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id      = aws_apigatewayv2_api.apigw_http_endpoint.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw_http_endpoint]
}


resource "aws_apigatewayv2_authorizer" "apigw_authorizer" {
  api_id                            = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.lambda_invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "techchallenge-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 0 
}

resource "aws_lambda_permission" "my_authorizer_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.apigw_http_endpoint.execution_arn}/*/*"
}


################################################################################
# ROUTES
################################################################################

resource "aws_apigatewayv2_route" "ponto_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_id      = aws_apigatewayv2_authorizer.apigw_authorizer.id
  authorization_type = "CUSTOM"
  route_key          = "ANY /ponto/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on         = [aws_apigatewayv2_integration.apigw_integration, aws_apigatewayv2_authorizer.apigw_authorizer]
}


resource "aws_apigatewayv2_route" "relatorio_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorizer_id      = aws_apigatewayv2_authorizer.apigw_authorizer.id
  authorization_type = "CUSTOM"
  route_key          = "ANY /relatorio/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on         = [aws_apigatewayv2_integration.apigw_integration, aws_apigatewayv2_authorizer.apigw_authorizer]
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorization_type = "NONE"
  route_key          = "ANY /auth/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on         = [aws_apigatewayv2_integration.apigw_integration]
}

resource "aws_apigatewayv2_route" "rabbit_route" {
  api_id             = aws_apigatewayv2_api.apigw_http_endpoint.id
  authorization_type = "NONE"
  route_key          = "ANY /rabbitmanagement/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on         = [aws_apigatewayv2_integration.apigw_integration]
}