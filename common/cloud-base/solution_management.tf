################################################
################ Bastion
################################################

output "devops-management-public_ip" {
  value = aws_instance.devops-management.*.public_ip
}

output "devops-management-private_dns" {
  value = aws_instance.devops-management.*.private_dns
}

output "devops-management-private_ip" {
  value = aws_instance.devops-management.*.private_ip
}

variable "instancesize_devops-management" {
  description = "instance type for api gateway"
  default     = "t3.small"
}

//Create the private node general userdata script.
data "template_file" "setup-devops-management" {
  template = file("./helper_scripts/setup-node.sh")
  vars = {
    availability_zone = aws_subnet.COMMON_MGT[0].availability_zone
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "devops-management" {
  ## only create in primary
  #count         = "${length(aws_subnet.COMMON_MGT.*.ids)}"
  count = 1

  ami                         = var.linux_region_ami[local.region]
  instance_type               = var.instancesize_devops-management
  subnet_id                   = aws_subnet.COMMON_MGT[count.index].id
  user_data                   = data.template_file.setup-devops-management.*.rendered[count.index]
  key_name                    = local.awskeypair_internal_node
  iam_instance_profile        = aws_iam_instance_profile.devops-management.name
  associate_public_ip_address = "false"
  disable_api_termination     = "false"
  
  vpc_security_group_ids = flatten([
    aws_security_group.common-internal.id,
    [
      aws_security_group.devops-management.id
    ]
  ])
  
  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-devops-management${count.index + 1}-${aws_subnet.COMMON_MGT[count.index].availability_zone}"
      "az"   = aws_subnet.COMMON_MGT[count.index].availability_zone
    },
  )
}

