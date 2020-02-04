variable "instancesize_universalmessaging" {
  description = "instance type for universalmessaging"
  default = "m5.large"
}

variable "instancecount_universalmessaging" {
  description = "number of nodes"
  default = "1"
}

################################################
################ Universal Messaging
################################################

output "dns_universalmessaging" {
  value = "${aws_instance.universalmessaging.*.private_dns}"
}

resource "aws_route53_record" "universalmessaging-a-record" {
    count = "${lookup(var.solution_enable, "messaging") == "true" ? var.instancecount_universalmessaging : 0}"

    zone_id = "${data.aws_route53_zone.main-internal.zone_id}"
    name = "${local.name_prefix}-universalmessaging${count.index+1}.${data.aws_route53_zone.main-internal.name}"
    type = "A"
    ttl  = 300
    records = [
        "${element(aws_instance.universalmessaging.*.private_ip,count.index)}"
    ]
}

//Create the private node general userdata script.
data "template_file" "setup-universalmessaging" {
  template = "${file("./helper_scripts/setup-private-node.sh")}"
  vars {
    availability_zone = "${data.aws_subnet.COMMON_APPS.0.availability_zone}"
  }
}

resource "aws_instance" "universalmessaging" {
  count = "${lookup(var.solution_enable, "messaging") == "true" ? var.instancecount_universalmessaging : 0}"

  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_universalmessaging}"
  subnet_id           = "${data.aws_subnet.COMMON_APPS.*.id[count.index]}"
  key_name            = "${local.awskeypair_internal_node}"
  user_data           = "${data.template_file.setup-universalmessaging.rendered}"
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 30
    volume_type = "standard"
  }

  vpc_security_group_ids = [
    "${local.common_secgroups}",
    "${list(
      aws_security_group.universalmessaging.id
    )}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    local.linux_tags,
    map(
      "Name", "${local.name_prefix}-universalmessaging-${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_APPS.*.availability_zone[count.index]}"
    )
  )}"
}