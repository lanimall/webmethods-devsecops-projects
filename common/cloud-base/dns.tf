output "dns-main-external-apex" {
  value = local.dns_main_external_apex
}

output "dns-main-internal-apex" {
  value = local.dns_main_internal_apex
}

locals {
  dns_main_external_apex = substr(
    aws_route53_zone.main-external.name,
    0,
    length(aws_route53_zone.main-external.name) - 1,
  )
  dns_main_internal_apex = substr(
    aws_route53_zone.main-internal.name,
    0,
    length(aws_route53_zone.main-internal.name) - 1,
  )
}

resource "aws_route53_zone" "main-external" {
  name    = var.resources_external_dns_apex
  comment = "Main Public DNS for demo project [${var.application_code}] - Managed by Terraform"

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-Main External Public DNS"
    },
  )
}

//Create the internal DNS.
resource "aws_route53_zone" "main-internal" {
  name    = var.resources_internal_dns_apex
  comment = "Main Internal DNS for demo project [${var.application_code}] - Managed by Terraform"
  vpc {
    vpc_id = aws_vpc.main.id
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-Main Internal DNS"
    },
  )
}

