resource "aws_api_gateway_rest_api" "fred_ball_api" {
  name        = "FredBallApi"
  description = "Backend APi for Fred Ball Diary"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.fred_ball_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.fred_ball_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.fred_ball_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.fred_ball_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.fred_ball_api.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.fred_ball_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.fred_ball_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.fred_ball_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.fred_ball_api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "fred_ball_api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.fred_ball_api.id}"
#   stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.fred_ball_api.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.fred_ball_api.execution_arn}/*/*"
}

resource "aws_route53_record" "api_alias" {
  zone_id = module.zones.id
  name    = "api.fredball.co.uk"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
    evaluate_target_health = false
  }
}


resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.fred_ball_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.fred_ball_api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name               = "api.fredball.co.uk"
  certificate_arn  = module.api_acm_us_east_1.acm_certificate_arn
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.fred_ball_api.id
  stage_name  = aws_api_gateway_stage.dev_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name

}
