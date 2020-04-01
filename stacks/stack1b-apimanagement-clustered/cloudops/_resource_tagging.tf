locals {
  common_tags_base = {
    "Application_Name"      = var.application_name
    "Application_Code"      = var.application_code
    "Environment"           = var.environment_code
    "Owners"                = var.owners
    "Organization"          = var.organization
    "Team"                  = var.team
    "Provisioning_Type"     = var.provisioning_type
    "Provisioning_SCM"      = var.provisioning_git
    "Provisoning_Workspace" = terraform.workspace
    "Provisoning_Stack"     = var.provisioning_stack
    "Provisoning_Stack_Description" = var.provisioning_stack_description
  }

  common_tags = merge(
    local.common_tags_base,
    {
      "Provisoning_UUID"   = random_id.main.hex
    },
  )

  common_ec2_tags = merge(
    local.common_tags
  )

  common_instance_windows_tags = merge(
    local.common_ec2_tags,
    {
      "OS_Family"         = var.windows_family
      "OS_Architecture"   = var.windows_arch
      "OS_Description"    = var.windows_os_description
    }
  )
  
  common_instance_linux_tags = merge(
    local.common_ec2_tags,
    {
      "OS_Family"         = var.linux_family
      "OS_Architecture"   = var.linux_arch
      "OS_Description"    = var.linux_os_description
    }
  )
}