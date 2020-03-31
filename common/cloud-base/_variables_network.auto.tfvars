subnet_shortname_dmz="COMMON_DMZ"
subnet_shortname_dmz_size="xsmall"
subnet_shortname_dmz_index="0"
subnet_shortname_management="COMMON_MGT"
subnet_shortname_management_size="small"
subnet_shortname_management_index="0"
subnet_shortname_web="COMMON_WEB"
subnet_shortname_web_size="large"
subnet_shortname_web_index="0"
subnet_shortname_apps="COMMON_APPS"
subnet_shortname_apps_size="large"
subnet_shortname_apps_index="1"
subnet_shortname_data="COMMON_DATA"
subnet_shortname_data_size="medium"
subnet_shortname_data_index="0"

# mapping between the region and the availability zones we want to use
# using 2 availability zones per region
availability_zones_mapping = {
    "us-east-1" = "us-east-1a,us-east-1b"
    "us-east-2" = "us-east-2a,us-east-2b"
    "us-west-1" = "us-west-1a,us-west-1b"
    "us-west-2" = "us-west-2a,us-west-2b"
}

# vpc_cidr_prefix
vpc_cidr_prefix = "10.0"

# Total size for the VPC
vpc_cidr_suffix="0.0/16"

### Distinct non-overalpping subnets spaces for different sizes of subnets
### each /18 = 16382 hosts
subnet_allocation_map_suffixes = {
    "xsmall" = "0.0/18"
    "small"  = "64.0/18"
    "medium" = "128.0/18"
    "large"  = "192.0/18"
}

### subnets sizes
#### 7 - results in 128 subnets with 126 usable hosts each
#### 6 - results in 64 subnets with 254 usable hosts each
#### 5 - results in 32 subnets with 510 usable hosts each
#### 4 - results in 16 subnets with 1022 usable hosts each
subnet_allocation_newbit_size = {
    "xsmall" = "7"
    "small"  = "6"
    "medium" = "5"
    "large"  = "4"
}