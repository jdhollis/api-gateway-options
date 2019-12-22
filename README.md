# api-gateway-options

This is a Terraform version of what API Gateway creates when you "Enable CORS" for a resource (with a couple of configurable extras to boot).

## Usage

```hcl
resource "aws_route53_record" "site" {
  # …
}

resource "aws_api_gateway_rest_api" "site" {
  # …
}

locals {
  dependency_hashes = [
    md5(file("${path.module}/proxy.tf")),
  ]

  combined_hash = md5(join("\n", local.dependency_hashes))
}

resource "aws_api_gateway_deployment" "site" {
  depends_on = [
    aws_api_gateway_integration.proxy,
    module.options_proxy.id,
  ]

  rest_api_id       = aws_api_gateway_rest_api.site.id
  stage_name        = var.env
  stage_description = local.combined_hash  # This is a convenient way to force a fresh deployment if any of the underlying resources change.
}

resource "aws_api_gateway_method_settings" "site" {
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.site.id

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }

  stage_name = aws_api_gateway_deployment.site.stage_name
}

resource "aws_api_gateway_resource" "proxy" {
  parent_id   = aws_api_gateway_rest_api.site.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.site.id
}

module "options_proxy" {
  source = "github.com/jdhollis/api-gateway-options"

  allow_headers = "'content-type,authorization,x-amz-date,x-api-key,x-amz-security-token,x-csrf-token'"
  allow_methods = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
  allow_origin  = var.allow_origin_override != "" ? var.allow_origin_override : "https://${aws_route53_record.site.name}" # var.allow_origin_override makes it easier to work with API Gateway when in local development
  resource_id   = aws_api_gateway_resource.proxy.id
  rest_api_id   = aws_api_gateway_rest_api.site.id
}
```
