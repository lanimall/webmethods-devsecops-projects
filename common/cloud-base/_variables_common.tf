variable "tfconnect_cloud_profile" {
  description = "cloud profile to use for terraform connection"
}

variable "cloud_region" {
  description = "cloud region to to use for the project"
}

variable "application_name" {
  description = "General Project Name (for tagging)"
}

variable "application_code" {
  description = "application name code (use short name if possible, because some resources have length limit on its name)"
}

variable "environment_code" {
  description = "environment code level - dev, test, impl, prod"
}

variable "timeouts" {
  description = "Updated Terraform resource management timeouts"
  default = {
    "create" = "40m"
    "update" = "80m"
    "delete" = "40m"
  }
}