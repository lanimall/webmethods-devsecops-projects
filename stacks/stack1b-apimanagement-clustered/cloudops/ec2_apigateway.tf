variable "instancecount_apigateway" {
  description = "number of api gateway nodes"
  default     = "2"
}

variable "instancesize_apigateway" {
  description = "instance type for api gateway"
  default     = "m5.xlarge"
}

################################################
################ outputs
################################################

output "apigateway_dns" {
  value = aws_instance.apigateway.*.private_dns
}

output "apigateway_dns_custom" {
  value = aws_route53_record.apigateway-a-record.*.name
}

output "apigateway_ui_external_hostname" {
  value = "${var.apigateway_ui_external_host_name}.${local.dns_main_external_apex}"
}

output "apigateway_runtime_external_hostname" {
  value = "${var.apigateway_ui_external_host_name}.${local.dns_main_external_apex}"
}

################################################
################ DNS
################################################

resource "aws_route53_record" "apigateway-a-record" {
  count = var.instancecount_apigateway

  zone_id = data.aws_route53_zone.main-internal.zone_id
  name    = "apigateway${count.index + 1}.${local.name_prefix_long}.${data.aws_route53_zone.main-internal.name}"
  type    = "A"
  ttl     = 300
  records = [
    aws_instance.apigateway[count.index].private_ip
  ]
}

################################################
################ Instance
################################################

//Create the private node general userdata script.
data "template_file" "setup_apigateway" {
  count = var.instancecount_apigateway
  
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
  }
}

resource "aws_instance" "apigateway" {
  count = var.instancecount_apigateway

  ami                         = var.linux_region_ami[local.region]
  instance_type               = var.instancesize_apigateway
  subnet_id                   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].id
  user_data                   = data.template_file.setup_apigateway[count.index].rendered
  key_name                    = local.aws_key_pair_internalnode
  iam_instance_profile        = data.aws_iam_instance_profile.app_node_role.name
  associate_public_ip_address = "false"
  disable_api_termination     = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 30
    volume_type = "standard"
  }

  volume_tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-apigateway${count.index + 1}-${data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
    },
  )

  vpc_security_group_ids = flatten([
    local.base_aws_security_group_commoninternal,
    [ 
      aws_security_group.apigateway.id,
      aws_security_group.apigateway_terracotta.id
    ]
  ])

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_instance_linux_tags,
    {
      "Name" = "${local.name_prefix_long}-apigateway${count.index + 1}-${data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone}"
      "az"   = data.aws_subnet.COMMON_WEB[count.index%length(data.aws_subnet.COMMON_WEB)].availability_zone
    }
  )
}

################################################
################ Load Balancer
################################################

locals {
  apigateway_runtime-lb-name        = "apigw"
  apigateway_runtime-lb-protocol    = "HTTP"
  apigateway_runtime-lb-port        = 5555
  apigateway_runtime-lb-target-type = "instance"

  apigateway_ui-lb-name        = "apigw-ui"
  apigateway_ui-lb-protocol    = "HTTP"
  apigateway_ui-lb-port        = 9072
  apigateway_ui-lb-target-type = "instance"
}

resource "random_id" "apigateway_ui-lb" {
  keepers = {
    protocol    = local.apigateway_ui-lb-protocol
    port        = local.apigateway_ui-lb-port
    vpc_id      = data.aws_vpc.main.id
    target_type = local.apigateway_ui-lb-target-type
  }
  byte_length = 2
}

resource "random_id" "apigateway_runtime-lb" {
  keepers = {
    protocol    = local.apigateway_runtime-lb-protocol
    port        = local.apigateway_runtime-lb-port
    vpc_id      = data.aws_vpc.main.id
    target_type = local.apigateway_runtime-lb-target-type
  }
  byte_length = 2
}

################ API Gateway UI

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway_ui" {
  name                 = "${local.name_prefix_short}-${local.apigateway_ui-lb-name}-${random_id.apigateway_ui-lb.hex}"
  port                 = random_id.apigateway_ui-lb.keepers.port
  protocol             = random_id.apigateway_ui-lb.keepers.protocol
  vpc_id               = random_id.apigateway_ui-lb.keepers.vpc_id
  target_type          = random_id.apigateway_ui-lb.keepers.target_type

  slow_start           = 100
  deregistration_delay = 300

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/apigatewayui/login"
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
      "Name" = "${local.name_prefix_long}-${local.apigateway_ui-lb-name}-${random_id.apigateway_ui-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apigateway_ui" {
  count = var.instancecount_apigateway

  target_group_arn = aws_lb_target_group.apigateway_ui.arn
  target_id        = aws_instance.apigateway[count.index].id
}

resource "aws_alb_listener_rule" "apigateway_ui" {
  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.apigateway_ui.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apigateway_ui_external_host_name}.${local.dns_main_external_apex}"]
    }
  }
}

################ API Gateway Runtime

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway_runtime" {
  name                 = "${local.name_prefix_short}-${local.apigateway_runtime-lb-name}-${random_id.apigateway_runtime-lb.hex}"
  port                 = random_id.apigateway_runtime-lb.keepers.port
  protocol             = random_id.apigateway_runtime-lb.keepers.protocol
  vpc_id               = random_id.apigateway_runtime-lb.keepers.vpc_id
  target_type          = random_id.apigateway_runtime-lb.keepers.target_type

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
      "Name" = "${local.name_prefix_short}-${local.apigateway_runtime-lb-name}-${random_id.apigateway_runtime-lb.hex}"
    },
  )
}

resource "aws_lb_target_group_attachment" "apigateway_runtime" {
  count = var.instancecount_apigateway

  target_group_arn = aws_lb_target_group.apigateway_runtime.arn
  target_id        = aws_instance.apigateway[count.index].id
}

resource "aws_alb_listener_rule" "apigateway_runtime" {
  listener_arn = data.aws_lb_listener.main-public-alb-https.arn

  action {
    target_group_arn = aws_lb_target_group.apigateway_runtime.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["${var.apigateway_runtime_external_host_name}.${local.dns_main_external_apex}"]
    }
  }
}