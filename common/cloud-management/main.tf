provider "aws" {
  region = "${var.base_region}"
  profile = "${var.base_cloud_profile}"
}

################################################
################ Global configs
################################################

resource "random_id" "main" {
  keepers {
    vpc_id = "${data.aws_vpc.main.id}"
    tf_state = "${terraform.workspace}"
  }
  byte_length = 4
}

locals {
  name_prefix_unique_short = "${random_id.main.hex}"
  
  name_prefix = "${lower(join("-",list(
    replace(var.base_name_prefix_short,"_","-"),
    replace(var.resources_name_prefix,"_","-"),
    replace((terraform.workspace != "default" ? terraform.workspace : "master"),"_","-")
    ))
  )}"
  
  name_prefix_noworkspace = "${lower(join("-",list(
    replace(var.base_name_prefix_short,"_","-"),
    replace(var.resources_name_prefix,"_","-")
    ))
  )}"
  
  awskeypair_internal_node = "${var.base_internalnode_key_name}"

  ## if we want to stick to the same AMI for sure
  base_ami_linux = "${var.linux_region_ami["${var.base_region}"]}"
  base_ami_linux_user = "${var.linux_ami_user}"
  
  ## if we want to stick to the same AMI for sure
  base_ami_windows = "${var.windows_region_ami["${var.base_region}"]}"
  base_ami_windows_user = "${var.windows_ami_user}"
}

locals {
  common_tags = {
    "Project" = "${var.project_name}",
    "Project_Prefix" = "${var.resources_name_prefix}",
    "Project_Workspace" = "${terraform.workspace}",
    "Provisioning_Type" = "${var.project_provisioning_type}",
    "Provisioning_Project" = "${var.project_provisioning_git}",
    "Project_Owners" = "${var.project_owners}",
    "Project_Organization" = "${var.project_organization}"
  },
  common_instance_tags = {
    "Scheduler_Stop" = "DAILY",
    "Scheduler_Stop_Time" = "0100"
  },
  common_rds_tags = {
    "Scheduler_Stop" = "DAILY",
    "Scheduler_Stop_Time" = "0130"
  },
  common_secgroups = [
    "${data.aws_security_group.common-internal.id}"
  ],
  common_access_cidrs = [],
  windows_tags = {
    "OSFamily" = "Windows",
    "OS" = "${var.windows_os_description}"
  },
  linux_tags = {
    "OSFamily" = "Linux",
    "OS" = "${var.linux_os_description}"
  }
}