variable "instancesize_terracotta" {
  description = "instance type for abe"
  default     = "m5.xlarge"
}

variable "instancecount_terracotta" {
  description = "number of abe nodes"
  default     = "1"
}

################################################
################ ABE
################################################

output "terracotta_dns" {
  value = aws_instance.terracotta.*.private_dns
}

resource "aws_route53_record" "terracotta-a-record" {
  count = var.solution_enable["caching"] == "true" ? var.instancecount_terracotta : 0

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "${local.name_prefix_unique_short}-terracotta${count.index + 1}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    element(aws_instance.terracotta.*.private_ip, count.index),
  ]
}

//Create the private node general userdata script.
data "template_file" "setup-terracotta" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_APPS[0].availability_zone
  }
}

################ Instance
resource "aws_instance" "terracotta" {
  count = var.solution_enable["caching"] == "true" ? var.instancecount_terracotta : 0

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_terracotta
  subnet_id                   = data.aws_subnet.COMMON_APPS[count.index].id
  key_name                    = local.awskeypair_internal_node
  user_data                   = data.template_file.setup-terracotta.rendered
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 40
    volume_type = "standard"
  }

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    [aws_security_group.terracotta.id],
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.linux_tags,
    {
      "Name" = "${local.name_prefix}-terracotta-${data.aws_subnet.COMMON_APPS[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index].availability_zone
    },
  )
}

