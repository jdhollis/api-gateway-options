variable "allow_headers" {}
variable "allow_methods" {}
variable "allow_origin" {}
variable "resource_id" {}
variable "rest_api_id" {}

output "id" {
  value = aws_api_gateway_integration.options.id
}
