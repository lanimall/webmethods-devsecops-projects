provider "aws" {
  region = "${var.region}"
  profile = "${var.cloud_profile}"
}

################################################
################ Global configs
################################################

## key creation
resource "aws_key_pair" "internalnode" {
  key_name   = "${local.awskeypair_internal_node}"
  public_key = "${file(var.internalnode_key_path)}"
}

locals {
  vpc_cidr= "${var.vpc_cidr_prefix}.${var.vpc_cidr_suffix}"
  
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

  awskeypair_bastion_node = "${local.name_prefix_noworkspace}-${var.bastion_key_name}"
  awskeypair_internal_node = "${local.name_prefix_noworkspace}-${var.internalnode_key_name}"

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
  common_instance_tags = {
    "Scheduler_Stop" = "DAILY",
    "Scheduler_Stop_Time" = "0100"
  },
  common_rds_tags = {
    "Scheduler_Stop" = "DAILY",
    "Scheduler_Stop_Time" = "0130"
  },
  instance_tags_schedule_stop = {
    "Scheduler_Stop" = "DAILY",
    "Scheduler_Stop_Time" = "0100"
  },
  instance_tags_schedule_start = {
    "Scheduler_Start" = "DAILY_NO_WEEKEND",
    "Scheduler_Start_Time" = "1100"
  },
  instance_tags_retention = {
    "Retention" = "notset",
    "Retention_Reason" = "notset",
    "Retention_Requestor" = "notset",
    "Retention_EndDate" = "notset"
  },
  common_secgroups = [
    "${aws_security_group.common-internal.id}"
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

### useful to keep using the latest...but dangerous since instances will get re-created if AMI changes
data "aws_ami" "centos" {
  owners      = ["aws-marketplace"]
  most_recent = true

    filter {
        name   = "name"
        values = ["CentOS Linux 7*"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

### useful to keep using the latest...but dangerous since instances will get re-created if AMI changes
# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

data "aws_ami" "amazon_windows_2016" {
  most_recent = true
  owners      = ["amazon"]

  #filter {
  #  name   = "name"
  #  values = ["Windows_Server-2016-English-Full-Base-*"]
  #}

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-2019.09.11"]
  }
}