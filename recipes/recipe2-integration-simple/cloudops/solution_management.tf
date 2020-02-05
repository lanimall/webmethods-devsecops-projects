variable "instancesize_mws" {
  description = "instance type for MWS"
  default = "m5.2xlarge"
}

variable "instancecount_mws" {
  description = "number of nodes for MWS"
  default = "1"
}

################################################
################ MWS
################################################

output "dns_mws" {
  value = "${aws_instance.mws.*.private_dns}"
}

resource "aws_route53_record" "mws-a-record" {
    count = "${lookup(var.solution_enable, "management") == "true" ? var.instancecount_integration : 0}"

    zone_id = "${data.aws_route53_zone.main-internal.zone_id}"
    name = "${local.name_prefix_unique_short}-mws${count.index+1}.${data.aws_route53_zone.main-internal.name}"
    type = "A"
    ttl  = 300
    records = [
        "${element(aws_instance.mws.*.private_ip,count.index)}"
    ]
}

//Create the private node general userdata script.
data "template_file" "setup-mws" {
  template = "${file("./helper_scripts/setup-private-node.sh")}"
  vars {
    availability_zone = "${data.aws_subnet.COMMON_APPS.0.availability_zone}"
  }
}

resource "aws_instance" "mws" {
  count = "${lookup(var.solution_enable, "management") == "true" ? var.instancecount_mws : 0}"

  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_mws}"
  subnet_id           = "${data.aws_subnet.COMMON_APPS.*.id[count.index]}"
  key_name            = "${local.awskeypair_internal_node}"
  user_data           = "${data.template_file.setup-mws.rendered}"
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
      aws_security_group.mws.id
    )}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    local.linux_tags,
    map(
      "Name", "${local.name_prefix}-mws-${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}"
    )
  )}"
}