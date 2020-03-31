provider "aws" {
  region  = var.cloud_region
  profile = var.tfconnect_cloud_profile
}

output "cloud_region" {
  value = var.cloud_region
}

output "name_prefix_long" {
  value = local.name_prefix_long
}

output "name_prefix_short" {
  value = local.name_prefix_short
}

//  Define a random seed based on identifying vars
resource "random_id" "main" {
  keepers = {
    application_code = var.application_code
    environment_code = var.environment_code
    tf_state = terraform.workspace
  }
  byte_length = 3
}

locals {
  name_prefix_long = lower(
    replace(
      trimsuffix(
        join(
          "-",
          [
            var.application_code,
            var.environment_code,
            random_id.main.hex,
            terraform.workspace != "default" ? terraform.workspace: "",
          ]
        ),
        "-"
      ),
      "_", "-"
    )
  )

  ##some names cannot exceed some char length...we can use that random ID instead when needed
  name_prefix_short = length(local.name_prefix_long) < 16 ? local.name_prefix_long : join("-",substr(local.name_prefix_long, 0, 16 - 4),random_id.main.hex)
}
