include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs = {
    lambda_subnet_ids         = [""]
    lambda_security_group_id  = ""
  }
}

inputs = {
  lambda_subnet_ids         = dependency.network.outputs.lambda_subnet_ids
  lambda_security_group_id  = dependency.network.outputs.lambda_security_group_id
}

terraform {
  source = "../../../modules//api-gateway"
}
