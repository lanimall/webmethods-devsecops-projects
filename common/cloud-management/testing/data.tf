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

output "subnets-COMMON_DMZ-ids" {
  value = data.aws_subnet_ids.COMMON_DMZ.ids
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

locals {
  subnet_dmz_ids_sorted_by_az = values(
    zipmap(
      data.aws_subnet.COMMON_DMZ_unsorted.*.availability_zone,
      data.aws_subnet.COMMON_DMZ_unsorted.*.id,
    ),
  )
}

data "aws_subnet" "COMMON_DMZ" {
  count = length(local.subnet_dmz_ids_sorted_by_az)
  id    = element(local.subnet_dmz_ids_sorted_by_az, count.index)
}