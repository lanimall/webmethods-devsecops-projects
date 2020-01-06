output "commandcentral-private_dns" {
  value = "${aws_instance.commandcentral.*.private_dns}"
}

variable "instancesize_commandcentral" {
  description = "instance type for api gateway"
  default = "m5.large"
}

variable "instancecount_commandcentral" {
  description = "number of command central nodes"
  default = "1"
}

##only one, in primary zone
resource "aws_instance" "commandcentral" {
  count = "${var.instancecount_commandcentral}"

  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_commandcentral}"
  subnet_id           = "${data.aws_subnet.COMMON_MGT.*.id[count.index]}"
  user_data           = "${data.template_file.setup-private-node.rendered}"
  key_name            = "${local.awskeypair_internal_node}"
  iam_instance_profile = ""
  associate_public_ip_address = "false"
 
  # Storage for webmethods command central repository
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 75
    volume_type = "standard"
  }

  vpc_security_group_ids = [
    "${list(
      aws_security_group.webmethods-commandcentral.id
    )}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    local.linux_tags,
    map(
      "Name", "${local.name_prefix}-commandcentral-${data.aws_subnet.COMMON_MGT.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_MGT.*.availability_zone[count.index]}"
    )
  )}"
}