variable "cloud_profile" {
  description = "cloud profile to use"
}

variable "region" {
  description = "region to launch servers."
}

variable "project_owners" {
  description = "Project identifying owners"
}

variable "project_organization" {
  description = "Project identifying organization"
}

variable "project_provisioning_type" {
  description = "type of Provisioning"
  default     = "terraform"
}

variable "project_provisioning_git" {
  description = "project provisoning git url"
  default     = "https://git.softwareaggov.com:Fabien.Sanglier/saggov_cloud_env.git"
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

## Windows_Server-2016-English-Full-Base-2020.01.15 -- owner: amazon (801119661308)
variable "windows_region_ami" {
  type = map(string)
  default = {
    us-east-1    = "ami-02daaf23b3890d162"
    us-east-2    = "ami-0833104f83deab338"
    us-west-1    = "ami-08dc1ca51e27079b0"
    us-west-2    = "ami-09e71fb1baf16d0cd"
    ca-central-1 = "ami-0fcebaeb4fd311763"
  }
}

variable "windows_ami_user" {
  type    = string
  default = "Administrator"
}

variable "windows_os_description" {
  type    = string
  default = "Amazon Windows 2016 Base (2020.01.15)"
}