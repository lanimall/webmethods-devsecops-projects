###################### access to base state

variable "tfremotestate_s3_bucket_name" {
  description = "The bucket name where the base Terraform state was saved"
}

variable "tfremotestate_s3_bucket_region" {
  description = "The bucket region where the base Terraform state was saved"
}

variable "tfremotestate_s3_path" {
  description = "The bucket path where the base Terraform state was saved"
}

data "terraform_remote_state" "cloudbase_state" {
    backend = "s3"
    config = {
      bucket = "${var.tfremotestate_s3_bucket_name}"
      region = "${var.tfremotestate_s3_bucket_region}"
      key    = "${var.tfremotestate_s3_path}"
    }
}

###################### variables from base network

locals {
  base_vpc_id = data.terraform_remote_state.cloudbase_state.outputs.vpc_id
  base_availability_zones_mapping = data.terraform_remote_state.cloudbase_state.outputs.availability_zones_mapping
  base_aws_security_group_commoninternal = data.terraform_remote_state.cloudbase_state.outputs.aws_security_group_commoninternal
  base_dns_main_internal_zoneid=data.terraform_remote_state.cloudbase_state.outputs.dns_main_internal_zoneid
  base_dns_main_internal_apex=data.terraform_remote_state.cloudbase_state.outputs.dns_main_internal_apex
  base_dns_main_external_zoneid=data.terraform_remote_state.cloudbase_state.outputs.dns_main_external_zoneid
  base_dns_main_external_apex=data.terraform_remote_state.cloudbase_state.outputs.dns_main_external_apex
  base_main_public_alb_dns_name=data.terraform_remote_state.cloudbase_state.outputs.main_public_alb_dns_name
  base_main_public_alb_id=data.terraform_remote_state.cloudbase_state.outputs.main_public_alb_id
  base_main_public_alb_http_id=data.terraform_remote_state.cloudbase_state.outputs.main_public_alb_http_id
  base_main_public_alb_https_id=data.terraform_remote_state.cloudbase_state.outputs.main_public_alb_https_id
  base_subnet_shortname_dmz=data.terraform_remote_state.cloudbase_state.outputs.subnet_shortname_dmz
  base_subnet_shortname_web=data.terraform_remote_state.cloudbase_state.outputs.subnet_shortname_web
  base_subnet_shortname_apps=data.terraform_remote_state.cloudbase_state.outputs.subnet_shortname_apps
  base_subnet_shortname_data=data.terraform_remote_state.cloudbase_state.outputs.subnet_shortname_data
  base_subnet_shortname_management=data.terraform_remote_state.cloudbase_state.outputs.subnet_shortname_management
  base_internalnode_key_name=data.terraform_remote_state.cloudbase_state.outputs.internalnode_key_name
}

###################### get the VPC from ID

data "aws_vpc" "main" {
  id = local.base_vpc_id
}

###################### Reference to the internal DNS.

data "aws_route53_zone" "main-external" {
  zone_id = local.base_dns_main_external_zoneid
}

data "aws_route53_zone" "main-internal" {
  zone_id = local.base_dns_main_internal_zoneid
}

locals {
  dns_main_external_apex = substr(
    data.aws_route53_zone.main-external.name,
    0,
    length(data.aws_route53_zone.main-external.name) - 1,
  )
  dns_main_internal_apex = substr(
    data.aws_route53_zone.main-internal.name,
    0,
    length(data.aws_route53_zone.main-internal.name) - 1,
  )
}

###################### Reference to the public load balancer listener.

data "aws_lb" "main-public-alb" {
  arn = local.base_main_public_alb_id
}

data "aws_lb_listener" "main-public-alb-http" {
  arn = local.base_main_public_alb_http_id
}

data "aws_lb_listener" "main-public-alb-https" {
  arn = local.base_main_public_alb_https_id
}

###################### Reference to the various networks

##### DMZ subnets ######

data "aws_subnet_ids" "COMMON_DMZ" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_dmz
  }
}

data "aws_subnet" "COMMON_DMZ_unsorted" {
  count = length(data.aws_subnet_ids.COMMON_DMZ.ids)
  id    = tolist(data.aws_subnet_ids.COMMON_DMZ.ids)[count.index]
}

##### WEB subnets ######

data "aws_subnet_ids" "COMMON_WEB" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_web
  }
}

data "aws_subnet" "COMMON_WEB_unsorted" {
  count = length(data.aws_subnet_ids.COMMON_WEB.ids)
  id    = tolist(data.aws_subnet_ids.COMMON_WEB.ids)[count.index]
}

##### APPS subnets ######

data "aws_subnet_ids" "COMMON_APPS" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_apps
  }
}

data "aws_subnet" "COMMON_APPS_unsorted" {
  count = length(data.aws_subnet_ids.COMMON_APPS.ids)
  id    = tolist(data.aws_subnet_ids.COMMON_APPS.ids)[count.index]
}

##### Management subnets ######

data "aws_subnet_ids" "COMMON_MGT" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_management
  }
}

data "aws_subnet" "COMMON_MGT_unsorted" {
  count = length(data.aws_subnet_ids.COMMON_MGT.ids)
  id    = tolist(data.aws_subnet_ids.COMMON_MGT.ids)[count.index]
}

##### DATA subnets ######

data "aws_subnet_ids" "COMMON_DATA" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = local.base_subnet_shortname_data
  }
}

data "aws_subnet" "COMMON_DATA_unsorted" {
  count = length(data.aws_subnet_ids.COMMON_DATA.ids)
  id    = tolist(data.aws_subnet_ids.COMMON_DATA.ids)[count.index]
}

##### Sort subnets by AZ for predictable ordering ######

locals {
  subnet_dmz_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_DMZ_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_DMZ_unsorted.*.id,
    ),
  )
  subnet_web_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_WEB_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_WEB_unsorted.*.id,
    ),
  )
  subnet_apps_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_APPS_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_APPS_unsorted.*.id,
    ),
  )
  subnet_mgt_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_MGT_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_MGT_unsorted.*.id,
    ),
  )
  subnet_data_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_DATA_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_DATA_unsorted.*.id,
    ),
  )
}

data "aws_subnet" "COMMON_DMZ" {
  count = length(local.subnet_dmz_ids_sorted_by_az)
  id    = element(local.subnet_dmz_ids_sorted_by_az, count.index)
}

data "aws_subnet" "COMMON_WEB" {
  count = length(local.subnet_web_ids_sorted_by_az)
  id    = element(local.subnet_web_ids_sorted_by_az, count.index)
}

data "aws_subnet" "COMMON_APPS" {
  count = length(local.subnet_apps_ids_sorted_by_az)
  id    = element(local.subnet_apps_ids_sorted_by_az, count.index)
}

data "aws_subnet" "COMMON_MGT" {
  count = length(local.subnet_mgt_ids_sorted_by_az)
  id    = element(local.subnet_mgt_ids_sorted_by_az, count.index)
}

data "aws_subnet" "COMMON_DATA" {
  count = length(local.subnet_data_ids_sorted_by_az)
  id    = element(local.subnet_data_ids_sorted_by_az, count.index)
}