resource "aws_ssm_parameter" "cobudget_cors_origins" {
  name  = "cobudget-cors-origins"
  type  = "String"
  value = var.frontend_url
}

resource "aws_ssm_parameter" "cobudget_oauth_issuer" {
  name  = "cobudget-oauth-issuer"
  type  = "String"
  value = var.oauth_issuer
}