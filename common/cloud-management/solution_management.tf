################################################
################ Bastion
################################################

output "devops-management-public_ip" {
  value = "${aws_instance.devops-management.*.public_ip}"
}
output "devops-management-private_dns" {
  value = "${aws_instance.devops-management.*.private_dns}"
}
output "devops-management-private_ip" {
  value = "${aws_instance.devops-management.*.private_ip}"
}

variable "instancesize_devops-management" {
  description = "instance type for api gateway"
  default = "t3.small"
}

//  Launch configuration for the bastion
resource "aws_instance" "devops-management" {
  ## only create in primary
  #count         = "${length(data.aws_subnet.COMMON_MGT.*.ids)}"
  count = 1
  
  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_devops-management}"
  subnet_id           = "${data.aws_subnet.COMMON_MGT.*.id[count.index]}"
  user_data           = "${data.template_file.setup-private-node.rendered}"
  key_name            = "${local.awskeypair_internal_node}"
  iam_instance_profile = ""
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.devops-management.id}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-devops-management-${data.aws_subnet.COMMON_MGT.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_MGT.*.availability_zone[count.index]}"
    )
  )}"
}