################################################
################ Global configs
################################################

provider "aws" {
  region = var.region
  profile = var.cloud_profile
}

resource "random_id" "main" {
  keepers = {
    vpc_id   = data.aws_vpc.main.id
    tf_state = terraform.workspace
  }
  byte_length = 4
}

locals {
  name_prefix_unique_short = random_id.main.hex
  name_prefix_long = lower(
    join(
      "-",
      [
        local.base_name_prefix_unique_short,
        local.name_prefix_unique_short,
        lower(replace(var.resources_name_prefix, "_", "-")),
        replace(
          terraform.workspace != "default" ? terraform.workspace : "master","_","-"
        )
      ],
    ),
  )

  awskeypair_internal_node = local.base_internalnode_key_name

  ## if we want to stick to the same AMI for sure
  base_ami_linux      = var.linux_region_ami[var.region]
  base_ami_linux_user = var.linux_ami_user

  ## if we want to stick to the same AMI for sure
  base_ami_windows      = var.windows_region_ami[var.region]
  base_ami_windows_user = var.windows_ami_user
}

locals {
  common_tags_base = {
    "Project"              = var.project_name
    "Project_Prefix"       = var.resources_name_prefix
    "Project_Workspace"    = terraform.workspace
    "Provisioning_Type"    = var.project_provisioning_type
    "Provisioning_Project" = var.project_provisioning_git
    "Project_Owners"       = var.project_owners
    "Project_Organization" = var.project_organization
  }
  common_tags = merge(
    local.common_tags_base,
    {
      "Base_Project_ID"    = local.base_name_prefix_unique_short
      "Project_ID"         = local.name_prefix_unique_short
    },
  )
  common_instance_tags = {
    "Scheduler_Stop"      = "DAILY"
    "Scheduler_Stop_Time" = "0100"
  }
  common_rds_tags = {
    "Scheduler_Stop"      = "DAILY"
    "Scheduler_Stop_Time" = "0130"
  }
  common_secgroups = [
    data.aws_security_group.common-internal.id,
  ]
  common_access_cidrs = []
  windows_tags = {
    "OSFamily" = "Windows"
    "OS"       = var.windows_os_description
  }
  linux_tags = {
    "OSFamily" = "Linux"
    "OS"       = var.linux_os_description
  }
}

