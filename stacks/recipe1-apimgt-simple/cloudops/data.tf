###################### Get references to the various data source created by base

###################### get the VPC from ID

output "main-vpc" {
  value = data.aws_vpc.main.id
}

data "aws_vpc" "main" {
  id = var.base_main_vpc_id
}

###################### Security group which allows SSH/RDP access to a host from specific internal servers

data "aws_security_group" "common-internal" {
  id = var.base_main_security_group_common_internal_id
}

###################### Reference to the internal DNS.

output "dns-main-external-apex" {
  value = local.dns_main_external_apex
}

output "dns-main-internal-apex" {
  value = local.dns_main_internal_apex
}

data "aws_route53_zone" "main-external" {
  zone_id = var.base_resources_external_dns_zoneid
}

data "aws_route53_zone" "main-internal" {
  zone_id = var.base_resources_internal_dns_zoneid
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
  arn = var.base_main_public_alb_id
}

data "aws_lb_listener" "main-public-alb-https" {
  arn = var.base_main_public_alb_https_id
}

###################### Reference to the various networks

output "subnets-COMMON_DMZ" {
  value = data.aws_subnet.COMMON_DMZ.*.id
}

output "subnets-COMMON_WEB" {
  value = data.aws_subnet.COMMON_WEB.*.id
}

output "subnets-COMMON_APPS" {
  value = data.aws_subnet.COMMON_APPS.*.id
}

output "subnets-COMMON_MGT" {
  value = data.aws_subnet.COMMON_MGT.*.id
}

output "subnets-COMMON_DATA" {
  value = data.aws_subnet.COMMON_DATA.*.id
}

##### DMZ subnets ######

data "aws_subnet_ids" "COMMON_DMZ" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    ShortName = var.base_subnet_shortname_dmz
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
    ShortName = var.base_subnet_shortname_web
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
    ShortName = var.base_subnet_shortname_apps
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
    ShortName = var.base_subnet_shortname_management
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
    ShortName = var.base_subnet_shortname_data
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

