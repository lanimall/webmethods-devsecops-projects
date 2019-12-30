variable "project_name" {
  description = "Project Name"
  default = "Software AG Government Solutions Demo Cloud"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default = "sagdemo"
}

variable "resources_internal_dns" {
  description = "Internal DNS zone"
  default = "sagdemo.cloud.local"
}

variable "cloud_profile" {
  description = "cloud profile to use"
  default = "demogithub"
}

###### REGION SPECIFICATION ######
variable "region" {
  description = "region to launch servers."
  default = "us-east-2"
}

###### AVAILABILITY ZONES######
variable "azs" {
  default = {
    "us-east-1" = "us-east-1a"
    "us-east-2" = "us-east-2a"
    "us-west-1" = "us-west-1a"
    "us-west-2" = "us-west-2a"
  }
}

###### VPC NETWORK SPECIFICATION ######
variable "vpc_cidr_prefix" {
  description = "The CIDR block main prefix"
  default = "20.0"
}

variable "vpc_cidr_suffix" {
  description = "The CIDR block for the VPC"
  default = "0.0/16"
}

### calculated with ipcalc
### each /18 = 16382 hosts
variable subnet_allocation_map_suffixes {
  description = "Map of CIDR blocks to carve into subnets based on size"
  default = {
    "xsmall" = "0.0/18"
    "small"  = "64.0/18"
    "medium" = "128.0/18"
    "large"  = "192.0/18"
   }
}

#### 7 - results in 128 subnets with 126 usable hosts each
#### 6 - results in 64 subnets with 254 usable hosts each
#### 5 - results in 32 subnets with 510 usable hosts each
#### 4 - results in 16 subnets with 1022 usable hosts each
variable "newbit_size" {
  description = "Map the friendly name to our subnet bit mask"
  default = {
    "xsmall" = "7" 
    "small"  = "6" 
    "medium" = "5" 
    "large"  = "4"
  }
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

variable "bastion_key_name" {
  description = "secure bastion ssh key name"
  default = "bastion"
}

variable "bastion_publickey_path" {
  description = "My secure bastion ssh public key"
  default = "./helper_scripts/id_rsa_bastion.pub"
}