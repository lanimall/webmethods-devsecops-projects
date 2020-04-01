variable "instancecount_internaldatastore" {
  description = "number of elastic search nodes"
  default     = "3"
}

variable "instancesize_internaldatastore" {
  description = "instance type for elastic search nodes"
  default     = "m5.large"
}

################################################
################ outputs
################################################

output "apigw_internaldatastore_dns" {
  value = aws_instance.internaldatastore.*.private_dns
}

output "apigw_internaldatastore_dns_custom" {
  value = aws_route53_record.internaldatastore-a-record.*.name
}

################################################
################ DNS
################################################

resource "aws_route53_record" "internaldatastore-a-record" {
  count = var.instancecount_internaldatastore

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "apigateway-internaldatastore${count.index + 1}.${local.name_prefix_long}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.internaldatastore[count.index].private_ip
  ]
}

################################################
################ Instance
################################################

//Create the private node general userdata script.
data "template_file" "setup-internaldatastore" {
  count = var.instancecount_internaldatastore
  
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
  }
}

resource "aws_instance" "internaldatastore" {
  count = var.instancecount_internaldatastore

  ami                         = var.linux_region_ami[local.region]
  instance_type               = var.instancesize_internaldatastore
  subnet_id                   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].id
  user_data                   = data.template_file.setup-internaldatastore[count.index].rendered
  key_name                    = local.aws_key_pair_internalnode
  iam_instance_profile        = data.aws_iam_instance_profile.app_node_role.name
  associate_public_ip_address = "false"
  disable_api_termination     = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "standard"
  }

  volume_tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-apigateway-internaldatastore${count.index + 1}-${data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
    },
  )

  vpc_security_group_ids = flatten([
    local.base_aws_security_group_commoninternal,
    [ 
      aws_security_group.apigateway_internaldatastore.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-apigateway-internaldatastore${count.index + 1}-${data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
    },
  )
}