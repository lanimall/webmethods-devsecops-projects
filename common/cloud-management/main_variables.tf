variable "project_name" {
  description = "Project Name"
}

variable "project_owners" {
  description = "Project identifying owners"
}

variable "project_organization" {
  description = "Project identifying organization"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default     = "mgtlayer"
}

variable "solution_enable" {
  description = "create or delete a solution stack"
  default = {
    "commandcentral" = "true"
    "management"     = "true"
  }
}

variable "project_provisioning_type" {
  description = "type of Provisioning"
  default     = "terraform"
}

variable "project_provisioning_git" {
  description = "project provisoning git url"
  default     = "https://github.com/lanimall/webMethods-devops-terraform.git"
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
  type = map(string)
  default = {
    us-east-1    = "ami-02eac2c0129f6376b"
    us-east-2    = "ami-0f2b4fc905b0bd1f1"
    us-west-1    = "ami-074e2d6769f445be5"
    us-west-2    = "ami-01ed306a12b7d1c96"
    ca-central-1 = "ami-033e6106180a626d0"
  }
}

variable "linux_ami_user" {
  type    = string
  default = "centos"
}

variable "linux_os_description" {
  type    = string
  default = "CentOS Linux 7 x86_64 HVM EBS"
}

## Windows_Server-2016-English-Full-Base-2019.10.09 -- owner: amazon (801119661308)
variable "windows_region_ami" {
  type = map(string)
  default = {
    us-east-1    = "ami-027a14492d667b8f5"
    us-east-2    = "ami-0b8b049f0ac9d6ded"
    us-west-1    = "ami-00cb62f0977a10d07"
    us-west-2    = "ami-0df99cdd65bce4245"
    ca-central-1 = "ami-0c7609710809ad56e"
  }
}

variable "windows_ami_user" {
  type    = string
  default = "Administrator"
}

variable "windows_os_description" {
  type    = string
  default = "Amazon Windows 2016 Base"
}

