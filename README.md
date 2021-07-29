# AWS FastAPI Lambda
Create an API using AWS API Gateway, Lambda and FastAPI + Mangum (based on [this walkthrough](https://towardsdatascience.com/fastapi-aws-robust-api-part-1-f67ae47390f9)).

# Dev
```sh
cd api
make install
make install-dev
make serve
```
View the [API endpoints](http://localhost:8000/docs).

# Deploy
```sh
# Create the zip that will be used for the Lambda function
cd api
make zip

# Create the API gateway and Lambda function
export AWS_ACCESS_KEY_ID="some-access-key"
export AWS_SECRET_ACCESS_KEY="and-its-secret"
cd ../infra/env/dev/api-gateway
terragrunt apply
```

# Note
The API gateway proxy integration with the Lambda function does not include a `/` root path.  If you need a root path, you'll need to add this method integration:
```terraform
resource "aws_api_gateway_method" "api_gateway_root_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method             = aws_api_gateway_method.api_gateway_root_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}
```
