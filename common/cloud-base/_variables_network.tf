variable "resources_external_dns_apex" {
  description = "External DNS zone"
}

variable "resources_internal_dns_apex" {
  description = "Internal DNS zone"
}

### VPC default prefix to use
variable "vpc_cidr_prefix" {
  description = "The CIDR block first 2 octets for the VPC"
}

### VPC default suffix to use
variable "vpc_cidr_suffix" {
  description = "The CIDR block last 2 octets for the VPC"
}

variable "subnet_allocation_map_suffixes" {
  description = "Map of CIDR blocks to carve into subnets based on size"
}

### subnets sizes
variable "subnet_allocation_newbit_size" {
  description = "Map the friendly name to our subnet bit mask"
}

### Availability zones to use per region for all the subnets
variable "availability_zones_mapping" {
  description = "Mapping between the region and the availability zones we will use in that region"
}

variable "subnet_shortname_dmz" {
  description = "name of the DMZ subnet"
}

variable "subnet_shortname_dmz_size" {
  description = "size of the DMZ subnet"
}

variable "subnet_shortname_dmz_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_management" {
  description = "name of the Management subnet"
}

variable "subnet_shortname_management_size" {
  description = "size of the management subnet"
}

variable "subnet_shortname_management_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_web" {
  description = "name of the WEB subnet"
}

variable "subnet_shortname_web_size" {
  description = "size of the WEB subnet"
}

variable "subnet_shortname_web_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_apps" {
  description = "name of the APPS subnet"
}

variable "subnet_shortname_apps_size" {
  description = "size of the APPS subnet"
}

variable "subnet_shortname_apps_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_data" {
  description = "name of the DATA subnet"
}

variable "subnet_shortname_data_size" {
  description = "size of the DATA subnet"
}

variable "subnet_shortname_data_index" {
  description = "the subnet index within the type of sized subnet"
}