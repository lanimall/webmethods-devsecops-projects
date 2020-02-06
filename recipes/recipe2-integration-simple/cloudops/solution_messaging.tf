variable "instancesize_universalmessaging" {
  description = "instance type for universalmessaging"
  default     = "m5.large"
}

variable "instancecount_universalmessaging" {
  description = "number of nodes"
  default     = "1"
}

################################################
################ Universal Messaging
################################################

output "dns_universalmessaging" {
  value = aws_instance.universalmessaging.*.private_dns
}

resource "aws_route53_record" "universalmessaging-a-record" {
  count = var.solution_enable["messaging"] == "true" ? var.instancecount_universalmessaging : 0

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "${local.name_prefix_unique_short}-universalmessaging${count.index + 1}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    element(aws_instance.universalmessaging.*.private_ip, count.index),
  ]
}

//Create the private node general userdata script.
data "template_file" "setup-universalmessaging" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_APPS[0].availability_zone
  }
}

resource "aws_instance" "universalmessaging" {
  count = var.solution_enable["messaging"] == "true" ? var.instancecount_universalmessaging : 0

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_universalmessaging
  subnet_id                   = data.aws_subnet.COMMON_APPS[count.index].id
  key_name                    = local.awskeypair_internal_node
  user_data                   = data.template_file.setup-universalmessaging.rendered
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 30
    volume_type = "standard"
  }

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    [aws_security_group.universalmessaging.id],
  ])

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.linux_tags,
    {
      "Name" = "${local.name_prefix}-universalmessaging-${data.aws_subnet.COMMON_APPS[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index].availability_zone
    },
  )
}

