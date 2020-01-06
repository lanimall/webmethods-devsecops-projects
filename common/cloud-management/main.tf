provider "aws" {
  region = "${var.region}"
  profile = "${var.cloud_profile}"
}

################################################
################ Global configs
################################################

//Create the private node general userdata script.
data "template_file" "setup-private-node" {
  template = "${file("./helper_scripts/setup-private-node.sh")}"
}

locals {
  default_name_prefix = "${var.project_name}"
  name_prefix = "${lower(join("",list(
    replace(var.resources_name_prefix != "" ? var.resources_name_prefix : local.default_name_prefix,"_","-"),
    replace((terraform.workspace != "default" ? terraform.workspace : ""),"_","-")
    ))
  )}"
  
  name_prefix_noworkspace = "${lower(join("",list(
    replace(var.resources_name_prefix != "" ? var.resources_name_prefix : local.default_name_prefix,"_","-")
    ))
  )}"

  awskeypair_internal_node = "${var.internalnode_key_name}"

  ## if we want to stick to the same AMI for sure
  base_ami_linux = "${var.linux_region_ami["${var.region}"]}"
  base_ami_linux_user = "${var.linux_ami_user}"
  
  ## if we want to stick to the same AMI for sure
  base_ami_windows = "${var.windows_region_ami["${var.region}"]}"
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