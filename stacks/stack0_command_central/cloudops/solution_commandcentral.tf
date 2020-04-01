variable "instancesize_commandcentral" {
  description = "instance type for api gateway"
  default     = "m5.large"
}

variable "instancecount_commandcentral" {
  description = "number of command central nodes"
  ## only create in primary
  #count         = "${length(data.aws_subnet.COMMON_MGT.*.ids)}"
  default     = "1"
}

################################################
################ outputs
################################################

output "webmethods_commandcentral_dns" {
  value = aws_instance.commandcentral.*.private_dns
}

output "webmethods_commandcentral_dns_custom" {
  value = aws_route53_record.webmethods_commandcentral-a-record.*.name
}

output "webmethods_commandcentral_external_hostname" {
  value = "${var.commandcentral_external_host_name}.${local.dns_main_external_apex}"
}

################################################
################ DNS
################################################

resource "aws_route53_record" "webmethods_commandcentral-a-record" {
  count = var.instancecount_commandcentral

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "commandcentral${count.index + 1}.${local.name_prefix_long}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.commandcentral[count.index].private_ip
  ]
}

################################################
################ Instance
################################################

//Create the private node general userdata script.
data "template_file" "setup-commandcentral" {
  count = var.instancecount_commandcentral
  
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_MGT[count.index].availability_zone
  }
}

##only one, in primary zone
resource "aws_instance" "commandcentral" {
  count = var.instancecount_commandcentral

  ami                         = var.linux_region_ami[local.region]
  instance_type               = var.instancesize_commandcentral
  subnet_id                   = data.aws_subnet.COMMON_MGT[count.index].id
  user_data                   = data.template_file.setup-commandcentral[count.index].rendered
  key_name                    = local.base_internalnode_key_name
  associate_public_ip_address = "false"
  disable_api_termination     = "true"

  # Storage for webmethods command central repository
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 75
    volume_type = "standard"
  }

  volume_tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-commandcentral${count.index + 1}-${data.aws_subnet.COMMON_MGT[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_MGT[count.index].availability_zone
    },
  )

  vpc_security_group_ids = flatten([
    local.base_aws_security_group_commoninternal,
    [ 
      aws_security_group.webmethods-commandcentral.id 
    ]
  ])
  
  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-commandcentral${count.index + 1}-${data.aws_subnet.COMMON_MGT[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_MGT[count.index].availability_zone
    },
  )
}

################################################
################ Load Balancer
################################################

locals {
  commandcentral-lb-name        = "cce"
  commandcentral-lb-protocol    = "HTTP"
  commandcentral-lb-port        = 80
  commandcentral-lb-target-type = "instance"
}

resource "random_id" "commandcentral-lb" {
  keepers = {
    protocol    = local.commandcentral-lb-protocol
    port        = local.commandcentral-lb-port
    vpc_id      = data.aws_vpc.main.id
    target_type = local.commandcentral-lb-target-type
  }
  byte_length = 2
}

resource "aws_lb_target_group_attachment" "commandcentral" {
  count = var.instancecount_commandcentral

  target_group_arn = aws_lb_target_group.commandcentral.arn
  target_id        = aws_instance.commandcentral[count.index].id
  port             = 8091
}

#create a target group for the http reverse proxy instances
## FYI: "name" cannot be longer than 32 characters
resource "aws_lb_target_group" "commandcentral" {
  name                 = "${local.name_prefix_short}-${local.commandcentral-lb-name}-${random_id.commandcentral-lb.hex}"
  port                 = 8091
  protocol             = "HTTPS"
  vpc_id               = data.aws_vpc.main.id
  slow_start           = 100
  deregistration_delay = 300

  depends_on = [random_id.commandcentral-lb]

  lifecycle {
    create_before_destroy = true
  }

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/cce/web/"
    protocol            = "HTTPS"
    port                = 8091
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-${local.commandcentral-lb-name}-${random_id.commandcentral-lb.hex}"
    },
  )
}

resource "aws_alb_listener_rule" "commandcentral" {
  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.commandcentral.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.commandcentral_external_host_name}.${local.dns_main_external_apex}"]
    }
  }
}