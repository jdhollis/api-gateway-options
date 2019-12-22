resource "aws_api_gateway_method" "options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = var.resource_id
  rest_api_id   = var.rest_api_id
}

resource "aws_api_gateway_method_response" "options" {
  http_method = aws_api_gateway_method.options.http_method
  resource_id = var.resource_id

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
  }

  rest_api_id = var.rest_api_id
  status_code = "200"
}

resource "aws_api_gateway_integration" "options" {
  content_handling     = "CONVERT_TO_TEXT"
  http_method          = aws_api_gateway_method.options.http_method
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  resource_id = var.resource_id
  rest_api_id = var.rest_api_id
  type        = "MOCK"
}

resource "aws_api_gateway_integration_response" "options" {
  depends_on = [aws_api_gateway_integration.options]

  content_handling = "CONVERT_TO_TEXT"
  http_method      = aws_api_gateway_method.options.http_method
  resource_id      = var.resource_id

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
    "method.response.header.Access-Control-Allow-Headers"     = var.allow_headers
    "method.response.header.Access-Control-Allow-Methods"     = var.allow_methods
    "method.response.header.Access-Control-Allow-Origin"      = "'${var.allow_origin}'"
  }

  rest_api_id = var.rest_api_id
  status_code = aws_api_gateway_method_response.options.status_code
}
