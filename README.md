# AWS FastAPI Lambda
Creates an API using an AWS API Gateway and Lambda function, based on [this walkthrough](https://towardsdatascience.com/fastapi-aws-robust-api-part-1-f67ae47390f9).  The setup uses:

* **API:** [FastAPI](https://fastapi.tiangolo.com/) `+` [Mangum](https://mangum.io/)
* **Infrastructure:** [Terraform](https://www.terraform.io/) `+` [Terragrunt](https://terragrunt.gruntwork.io/)

Requests are sent to the API Gateway, which has one `/{proxy+}` resource.  This resource handles all requests using a [proxy integration with the Lambda function](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html).  Mangum acts as a wrapper, which allows FastAPI to handle the requests and create responses the API gateway can serve.  All logs are sent to CloudWatch log groups.

```js
          ┌─── AWS region ─────────────────────────────┐
          │                  ┌─── VPC: three AZs ────┐ │
          │                  │                       │ │
Request  ───►  API Gateway  ───►  Lambda (FastAPI)   │ │
          │                  │                       │ │
          │         │        └───────────│───────────┘ │
          │ ┌───────│────────────────────│───────────┐ │
          │ │       ▼      CloudWatch    ▼           │ │
          │ └────────────────────────────────────────┘ │
          └────────────────────────────────────────────┘
```

If performance becomes an issue, a CloudFront distribution could be added for API responses that are cacheable.

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

# Create the AWS infrastructure
cd ../infra/env/dev
terragrunt run-all plan   # to see all the goodness that will get created
terragrunt run-all apply  # create all the goodness
```

# Notes
## Root path
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
## API key
An API key is created and required by the API gateway.  You can retrieve the key from the API's usage plan in the AWS console.  To use the key:
```sh
curl --header "x-api-key: ${API_KEY_VALUE}" \
  https://${API_ID}.execute-api.${API_REGION}.amazonaws.com/dev/hello
```
