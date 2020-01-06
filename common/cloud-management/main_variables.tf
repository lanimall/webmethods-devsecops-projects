variable "project_name" {
  description = "Project Name"
  default = "Software AG Government Solutions Demo Cloud"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default = "sagdemo"
}

variable "project_provisioning_type" {
  description = "type of Provisioning"
  default = "terraform"
}

variable "project_provisioning_git" {
  description = "project provisoning git url"
  default = "https://github.com/lanimall/webMethods-devops-terraform.git"
}

variable "project_owners" {
  description = "Project identifying owners"
  default = "Fabien Sanglier"
}

variable "project_organization" {
  description = "Project identifying organization"
  default = "Software AG Government Solutions"
}

variable "resources_internal_dns" {
  description = "Internal DNS zone"
  default = "sagdemo.cloud.local"
}

variable "cloud_profile" {
  description = "cloud profile to use"
  default = "demogithub"
}

### Region to use
variable "region" {
  description = "region to launch servers."
  default = "us-east-2"
}

### VPC to use
variable "main_vpc_id" {
  description = "The ID of the target VPC"
}

variable "main_bastion_private_ip" {
  description = "ip of the bastion to use in the security group"
}

### VPC DNS
variable "vpc_dns_zonename" {
  description = "The hosted zone name for the VPC"
  default = "sag.cloud"
}

variable "internalnode_key_name" {
  description = "nodes to nodes ssh key name"
}

variable "subnet_shortname_dmz" {
  description = "name of the DMZ subnet"
  default = "COMMON_DMZ"
}

variable "subnet_shortname_management" {
  description = "name of the Management subnet"
  default = "COMMON_MGT"
}

variable "subnet_shortname_web" {
  description = "name of the WEB subnet"
  default = "COMMON_WEB"
}

variable "subnet_shortname_apps" {
  description = "name of the APPS subnet"
  default = "COMMON_APPS"
}

variable "subnet_shortname_data" {
  description = "name of the DATA subnet"
  default = "COMMON_DATA"
}

variable "timeouts" {
  description = "Updated Terraform resource management timeouts"
  default = {
    "create" = "40m"
    "update" = "80m"
    "delete" = "40m"
  }
}

## CentOS Linux 7 x86_64 HVM EBS 1905 // owner aws-marketplace
variable "linux_region_ami" {
  type = "map"
  default = {
      us-east-1      = "ami-02eac2c0129f6376b"
      us-east-2      = "ami-0f2b4fc905b0bd1f1"
      us-west-1      = "ami-074e2d6769f445be5"
      us-west-2      = "ami-01ed306a12b7d1c96"
      ca-central-1   = "ami-033e6106180a626d0"
  }
}

variable "linux_ami_user" {
  type = "string"
  default = "centos" 
}

variable "linux_os_description" {
  type = "string"
  default = "CentOS Linux 7 x86_64 HVM EBS" 
}

## Windows_Server-2016-English-Full-Base-2019.10.09 -- owner: amazon (801119661308)
variable "windows_region_ami" {
  type = "map"
  default = {
      us-east-1      = "ami-027a14492d667b8f5"
      us-east-2      = "ami-0b8b049f0ac9d6ded"
      us-west-1      = "ami-00cb62f0977a10d07"
      us-west-2      = "ami-0df99cdd65bce4245"
      ca-central-1   = "ami-0c7609710809ad56e"
  }
}

variable "windows_ami_user" {
  type = "string"
  default = "Administrator" 
}

variable "windows_os_description" {
  type = "string"
  default = "Amazon Windows 2016 Base" 
}