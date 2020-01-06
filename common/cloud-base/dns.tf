
//Create the internal DNS.
resource "aws_route53_zone" "internal" {
  name = "${var.resources_internal_dns}"
  comment = "Main Internal DNS"
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