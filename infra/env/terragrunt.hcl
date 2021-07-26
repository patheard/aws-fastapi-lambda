locals {
  vars    = read_terragrunt_config("../env_vars.hcl")
  region  = "ca-central-1"
}

inputs = {
  env           = local.vars.inputs.env
  project_name  = local.vars.inputs.project_name
  region        = local.region
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt        = true
    bucket         = "tfstate-aws-fastapi-lambda-${local.vars.inputs.env}"
    dynamodb_table = "terraform-lock"
    region         = local.region
    key            = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = file("./common/provider.tf")
}

generate "common_variables" {
  path      = "common_variables.tf"
  if_exists = "overwrite"
  contents  = file("./common/common_variables.tf")
}
