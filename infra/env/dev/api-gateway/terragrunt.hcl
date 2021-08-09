include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network", "../sqs"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    lambda_subnet_ids         = [""]
    lambda_security_group_id  = ""
  }
}

dependency "sqs" {
  config_path = "../sqs"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    message_queue_arn = ""
    message_queue_url = ""
  }
}

inputs = {
  lambda_subnet_ids         = dependency.network.outputs.lambda_subnet_ids
  lambda_security_group_id  = dependency.network.outputs.lambda_security_group_id
  message_queue_arn         = dependency.sqs.outputs.message_queue_arn
  message_queue_url         = dependency.sqs.outputs.message_queue_url
}

terraform {
  source = "../../../modules//api-gateway"
}
