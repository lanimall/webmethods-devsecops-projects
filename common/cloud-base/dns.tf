
resource "aws_route53_zone" "main-external" {
  name = "${var.resources_external_dns_apex}"
  comment = "Main Public DNS for demo project [${var.project_name}] - Managed by Terraform"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-Main External Public DNS"
    )
  )}"
}

//Create the internal DNS.
resource "aws_route53_zone" "main-internal" {
  name = "${var.resources_internal_dns_apex}"
  comment = "Main Internal DNS for demo project [${var.project_name}] - Managed by Terraform"
  vpc {
    vpc_id = "${aws_vpc.main.id}"
  }
  
  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-Main Internal DNS"
    )
  )}"
}