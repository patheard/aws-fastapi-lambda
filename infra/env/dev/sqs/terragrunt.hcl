include {
  path = find_in_parent_folders()
}

inputs = {
  lambda_producer_function_name = "FastAPI"
  max_receive_count             = 5
}

terraform {
  source = "../../../modules//sqs"
}
