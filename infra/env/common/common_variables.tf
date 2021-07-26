variable "env" {
  description = "(Required) The current running environment"
  type        = string
}

variable "project_name" {
  description = "(Required) Name of the project, used for top level resources and tagging"
  type        = string
}

variable "region" {
  description = "(Required) The region to build infra in"
  type        = string
}
