###################### variables from base

variable "base_cloud_profile" {
  description = "cloud profile to use"
}

variable "base_cloud_profile" {
  description = "cloud profile to use"
}

### Region to use
variable "base_region" {
  description = "region to launch servers."
}

variable "base_main_vpc_id" {
  description = "The ID of the target VPC"
}

variable "base_name_prefix_unique_short" {
  description = "The unique base name prefix"
}

variable "base_name_prefix_short" {
  description = "The base name prefix short format"
}

variable "base_name_prefix_long" {
  description = "The base name prefix long format"
}

variable "base_resources_internal_dns_zoneid" {
  description = "Internal DNS zone"
}

variable "base_resources_external_dns_zoneid" {
  description = "External DNS zone"
}

variable "base_main_public_alb_id" {
  type = "string"
}

variable "base_main_public_alb_https_id" {
  type = "string"
}

variable "base_main_security_group_common_internal_id" {
  type = "string"
}

variable "base_main_bastion_private_ip" {
  description = "ip of the bastion to use in the security group"
}

variable "base_internalnode_key_name" {
  description = "nodes to nodes ssh key name"
}

variable "base_subnet_shortname_dmz" {
  description = "name of the DMZ subnet"
  default = "COMMON_DMZ"
}

variable "base_subnet_shortname_management" {
  description = "name of the Management subnet"
  default = "COMMON_MGT"
}

variable "base_subnet_shortname_web" {
  description = "name of the WEB subnet"
  default = "COMMON_WEB"
}

variable "base_subnet_shortname_apps" {
  description = "name of the APPS subnet"
  default = "COMMON_APPS"
}

variable "base_subnet_shortname_data" {
  description = "name of the DATA subnet"
  default = "COMMON_DATA"
}