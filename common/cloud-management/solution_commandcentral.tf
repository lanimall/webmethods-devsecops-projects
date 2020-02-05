output "commandcentral-private_dns" {
  value = aws_instance.commandcentral.*.private_dns
}

variable "instancesize_commandcentral" {
  description = "instance type for api gateway"
  default     = "m5.large"
}

variable "instancecount_commandcentral" {
  description = "number of command central nodes"
  default     = "1"
}

//Create the private node general userdata script.
data "template_file" "setup-commandcentral" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_MGT[0].availability_zone
  }
}

##only one, in primary zone
resource "aws_instance" "commandcentral" {
  count = var.solution_enable["commandcentral"] == "true" ? var.instancecount_commandcentral : 0

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_commandcentral
  subnet_id                   = data.aws_subnet.COMMON_MGT[count.index].id
  user_data                   = data.template_file.setup-commandcentral.*.rendered[count.index]
  key_name                    = local.awskeypair_internal_node
  iam_instance_profile        = ""
  associate_public_ip_address = "false"

  # Storage for webmethods command central repository
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 75
    volume_type = "standard"
  }

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    [ 
      aws_security_group.webmethods-commandcentral.id 
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.common_instance_tags,
    local.linux_tags,
    {
      "Name" = "${local.name_prefix}-commandcentral-${data.aws_subnet.COMMON_MGT[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_MGT[count.index].availability_zone
    },
  )
}

################################################
################ DNS
################################################

resource "aws_route53_record" "webmethods_commandcentral-a-record" {
  count = var.solution_enable["commandcentral"] == "true" ? var.instancecount_commandcentral : 0

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "commandcentral.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = aws_instance.commandcentral.*.private_ip
}

################################################
################ Load Balancer
################################################

resource "aws_lb_target_group_attachment" "commandcentral" {
  count = var.solution_enable["commandcentral"] == "true" ? var.instancecount_commandcentral : 0

  target_group_arn = aws_lb_target_group.commandcentral[0].arn
  target_id        = aws_instance.commandcentral[0].id
  port             = 8091
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "commandcentral" {
  count = var.solution_enable["commandcentral"] == "true" ? var.instancecount_commandcentral : 0

  name                 = "commandcentral-tg"
  port                 = 8091
  protocol             = "HTTPS"
  vpc_id               = data.aws_vpc.main.id
  slow_start           = 100
  deregistration_delay = 300

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
      "Name" = "${local.name_prefix}-commandcentral-tg"
    },
  )
}

resource "aws_alb_listener_rule" "commandcentral" {
  count = var.solution_enable["commandcentral"] == "true" ? var.instancecount_commandcentral : 0

  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.commandcentral[0].arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["commandcentral.${local.dns_main_external_apex}"]
    }
  }
}

