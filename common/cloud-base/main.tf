provider "aws" {
  region = "${var.region}"
  profile = "${var.cloud_profile}"
}

################################################
################ Global configs
################################################

## key creation for internal nodes
resource "aws_key_pair" "internalnode" {
  key_name   = "${local.awskeypair_internal_node}"
  public_key = "${file(local.awskeypair_internal_keypath)}"
}

## key creation for bastion nodes
resource "aws_key_pair" "bastion" {
  key_name   = "${local.awskeypair_bastion_node}"
  public_key = "${file(local.awskeypair_bastion_keypath)}"
}

resource "random_id" "main" {
  keepers {
    vpc_id = "${aws_vpc.main.id}"
    tf_state = "${terraform.workspace}"
  }
  byte_length = 4
}

locals {
  vpc_cidr= "${var.vpc_cidr_prefix}.${var.vpc_cidr_suffix}"
  name_prefix_unique_short = "${random_id.main.hex}"
  name_prefix_long = "${lower(join("-",list(
    replace(var.resources_name_prefix,"_","-"),
    replace((terraform.workspace != "default" ? terraform.workspace : "master"),"_","-")
    ))
  )}"
  name_prefix_short = "${lower(replace(var.resources_name_prefix,"_","-"))}"

  awskeypair_bastion_node = "${local.name_prefix_unique_short}-${var.bastion_key_name}"
  awskeypair_bastion_keypath = "${var.local_secrets_dir}/${var.bastion_publickey_path}"
  awskeypair_internal_node = "${local.name_prefix_unique_short}-${var.internalnode_key_name}"
  awskeypair_internal_keypath = "${var.local_secrets_dir}/${var.internalnode_publickey_path}"

  lb_ssl_cert_key = "${var.local_secrets_dir}/${var.lb_ssl_cert_key}"
  lb_ssl_cert_pub = "${var.local_secrets_dir}/${var.lb_ssl_cert_pub}"
  lb_ssl_cert_ca = "${var.local_secrets_dir}/${var.lb_ssl_cert_ca}"

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