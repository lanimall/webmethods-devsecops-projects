provider "aws" {
  region = "${var.region}"
  profile = "${var.cloud_profile}"
}

################################################
################ Global configs
################################################

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
    "Provisioning" = "terraform",
    "Provisioning_Project" = "https://github.com/lanimall/webMethods-devops-terraform.git",
    "Owner" = "Fabien Sanglier",
    "Organization" = "Software AG Government Solutions"
  },
  common_secgroups = [
    "${aws_security_group.common-internal.id}"
  ],
  common_access_cidrs = [],
  windows_tags = {
    "OSFamily" = "Windows",
    "OS" = "Amazon Windows 2016 Base"
  },
  linux_tags = {
    "OSFamily" = "Linux",
    "OS" = "CentOS Linux 7 x86_64 HVM EBS"
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