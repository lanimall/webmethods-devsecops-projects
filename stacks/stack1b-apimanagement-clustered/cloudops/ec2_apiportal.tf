variable "instancecount_apiportal" {
  description = "number of api portal nodes"
  default     = "1"
}

variable "instancesize_apiportal" {
  description = "instance type for api portal"
  default     = "m5.xlarge"
}

################################################
################ outputs
################################################

output "apiportal_dns" {
  value = aws_instance.apiportal.*.private_dns
}

output "apiportal_dns_custom" {
  value = aws_route53_record.apiportal-a-record.*.name
}

output "apiportal_external_hostname" {
  value = "${var.apiportal_external_host_name}.${local.dns_main_external_apex}"
}

################################################
################ DNS
################################################

resource "aws_route53_record" "apiportal-a-record" {
  count = var.instancecount_apiportal

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "apiportal${count.index + 1}.${local.name_prefix_long}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.apiportal[count.index].private_ip
  ]
}

################################################
################ Instance
################################################

//Create the private node general userdata script.
data "template_file" "setup-apiportal" {
  count = var.instancecount_apiportal
  
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].availability_zone
  }
}

resource "aws_instance" "apiportal" {
  count = var.instancecount_apiportal

  ami                         = var.linux_region_ami[local.region]
  instance_type               = var.instancesize_apiportal
  subnet_id                   = data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].id
  user_data                   = data.template_file.setup-apiportal[count.index].rendered
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
      "Name" = "${local.name_prefix_long}-apiportal${count.index + 1}-${data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].availability_zone
    },
  )

  vpc_security_group_ids = flatten([
    local.base_aws_security_group_commoninternal,
    [ 
      aws_security_group.apiportal.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-apiportal${count.index + 1}-${data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index%length(data.aws_subnet.COMMON_APPS)].availability_zone
    },
  )
}

################################################
################ Load Balancer
################################################

locals {
  apiportal-lb-name        = "apiportal"
  apiportal-lb-protocol    = "HTTP"
  apiportal-lb-port        = 18101
  apiportal-lb-target-type = "instance"
}

resource "random_id" "apiportal-lb" {
  keepers = {
    protocol    = local.apiportal-lb-protocol
    port        = local.apiportal-lb-port
    vpc_id      = data.aws_vpc.main.id
    target_type = local.apiportal-lb-target-type
  }
  byte_length = 2
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apiportal" {
  name                 = "${local.name_prefix_short}-${local.apiportal-lb-name}-${random_id.apiportal-lb.hex}"
  port                 = random_id.apiportal-lb.keepers.port
  protocol             = random_id.apiportal-lb.keepers.protocol
  vpc_id               = random_id.apiportal-lb.keepers.vpc_id
  target_type          = random_id.apiportal-lb.keepers.target_type

  slow_start           = 120
  deregistration_delay = 120

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    protocol            = "HTTP"
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
      "Name" = "${local.name_prefix_long}-${local.apiportal-lb-name}-${random_id.apiportal-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apiportal" {
  count = var.instancecount_apiportal

  target_group_arn = aws_lb_target_group.apiportal.arn
  target_id        = aws_instance.apiportal[count.index].id
}

resource "aws_alb_listener_rule" "apiportal" {
  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.apiportal.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apiportal_external_host_name}.${local.dns_main_external_apex}"]
    }
  }
}