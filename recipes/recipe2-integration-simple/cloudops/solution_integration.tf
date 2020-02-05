################################################
################ integration
################################################

output "integration_dns" {
  value = aws_instance.integration.*.private_dns
}

variable "instancesize_integration" {
  description = "instance type for integration"
  default     = "m5.large"
}

variable "instancecount_integration" {
  description = "number of integration nodes"
  default     = "1"
}

resource "aws_route53_record" "integration-a-record" {
  count = var.solution_enable["integration"] == "true" ? var.instancecount_integration : 0

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "${local.name_prefix_unique_short}-integration${count.index + 1}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    element(aws_instance.integration.*.private_ip, count.index),
  ]
}

//Create the private node general userdata script.
data "template_file" "setup-integration" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_APPS[0].availability_zone
  }
}

################ Instance
resource "aws_instance" "integration" {
  count = var.solution_enable["integration"] == "true" ? var.instancecount_integration : 0

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_integration
  subnet_id                   = data.aws_subnet.COMMON_APPS[count.index].id
  key_name                    = local.awskeypair_internal_node
  user_data                   = data.template_file.setup-integration.rendered
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "standard"
  }

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    [aws_security_group.integrationserver.id],
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.common_instance_tags,
    {
      "Name" = "${local.name_prefix}-integrationserver-${data.aws_subnet.COMMON_APPS[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index].availability_zone
    },
  )
}

resource "aws_lb_target_group_attachment" "is-runtime" {
  count = var.solution_enable["integration"] == "true" ? var.instancecount_integration : 0

  target_group_arn = aws_lb_target_group.is-runtime[0].arn
  target_id        = element(aws_instance.integration.*.id, count.index)
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "is-runtime" {
  count = var.solution_enable["integration"] == "true" ? 1 : 0

  name                 = "${local.name_prefix_unique_short}-is-runtime-tg"
  port                 = 5555
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
  slow_start           = 100
  deregistration_delay = 300

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/invoke/wm.server/ping"
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
      "Name" = "${local.name_prefix}-is-runtime-tg"
    },
  )
}

resource "aws_alb_listener_rule" "is-runtime" {
  count = var.solution_enable["integration"] == "true" ? 1 : 0

  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.is-runtime[0].arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${local.name_prefix_unique_short}-integration1.${local.dns_main_external_apex}"]
    }
  }
}

