variable "instancecount_apiportal" {
  description = "number of api portal nodes"
  default     = "1"
}

variable "instancesize_apiportal" {
  description = "instance type for api portal"
  default     = "m5.xlarge"
}

################################################
################ API Portal
################################################

output "apiportal_dns" {
  value = aws_instance.apiportal.*.private_dns
}

resource "aws_route53_record" "apiportal-a-record" {
  count = var.solution_enable["apiportal"] == "true" ? var.instancecount_apiportal : 0

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "${local.name_prefix_unique_short}-apiportal${count.index + 1}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    element(aws_instance.apiportal.*.private_ip, count.index),
  ]
}

//Create the private node general userdata script.
data "template_file" "setup-apiportal" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_APPS[0].availability_zone
  }
}

resource "aws_instance" "apiportal" {
  count = var.solution_enable["apiportal"] == "true" ? var.instancecount_apiportal : 0

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_apiportal
  subnet_id                   = data.aws_subnet.COMMON_APPS[count.index].id
  key_name                    = local.awskeypair_internal_node
  user_data                   = data.template_file.setup-apiportal.rendered
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 50
    volume_type = "standard"
  }

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    aws_security_group.apiportal.id
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.common_instance_tags,
    {
      "Name" = "${local.name_prefix}-apiportal-${data.aws_subnet.COMMON_APPS[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_APPS[count.index].availability_zone
    },
  )
}

################ Load Balancer

resource "aws_lb_target_group_attachment" "apiportal" {
  count = var.solution_enable["apiportal"] == "true" ? var.instancecount_apiportal : 0

  target_group_arn = aws_lb_target_group.apiportal[0].arn
  target_id        = element(aws_instance.apiportal.*.id, count.index)
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apiportal" {
  count = var.solution_enable["apiportal"] == "true" ? 1 : 0

  name                 = "${local.name_prefix_unique_short}-apiportal-tg"
  port                 = 18101
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
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
      "Name" = "${local.name_prefix}-apiportal-tg"
    },
  )
}

resource "aws_alb_listener_rule" "apiportal" {
  count = var.solution_enable["apiportal"] == "true" ? var.instancecount_apiportal : 0

  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.apiportal[0].arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${local.name_prefix_unique_short}-apiportal${count.index + 1}.${local.dns_main_external_apex}"]
    }
  }
}

