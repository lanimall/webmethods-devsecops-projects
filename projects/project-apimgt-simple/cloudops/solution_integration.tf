################################################
################ integration
################################################

output "integration_dns" {
  value = "${aws_instance.integration.*.private_dns}"
}

variable "instancesize_integration" {
  description = "instance type for integration"
  default = "m5.large"
}

variable "instancecount_integration" {
  description = "number of integration nodes"
  default = "1"
}

resource "aws_route53_record" "integration-a-record" {
    count = "${lookup(var.solution_enable, "integration") == "true" ? var.instancecount_integration : 0}"

    zone_id = "${data.aws_route53_zone.main-internal.zone_id}"
    name = "${local.name_prefix}-integration${count.index+1}.${data.aws_route53_zone.main-internal.name}"
    type = "A"
    ttl  = 300
    records = [
        "${element(aws_instance.integration.*.private_ip,count.index)}"
    ]
}

//Create the private node general userdata script.
data "template_file" "setup-integration" {
  template = "${file("./helper_scripts/setup-private-node.sh")}"
  vars {
    availability_zone = "${data.aws_subnet.COMMON_APPS.0.availability_zone}"
  }
}

################ Instance
resource "aws_instance" "integration" {
  count = "${lookup(var.solution_enable, "integration") == "true" ? var.instancecount_integration : 0}"

  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_integration}"
  subnet_id           = "${data.aws_subnet.COMMON_APPS.*.id[count.index]}"
  key_name            = "${local.awskeypair_internal_node}"
  user_data           = "${data.template_file.setup-integration.rendered}"
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "standard"
  }

  vpc_security_group_ids = [
    "${local.common_secgroups}",
    "${list(
      aws_security_group.webmethods-integrationserver.id
    )}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    local.common_instance_tags,
    map(
      "Name", "${local.name_prefix}-integrationserver-${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}"
    )
  )}"
}