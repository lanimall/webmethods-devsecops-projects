variable "instancecount_apigateway" {
  description = "number of api gateway nodes"
  default = "1"
}

variable "instancesize_apigateway" {
  description = "instance type for api gateway"
  default = "m5.xlarge"
}

################################################
################ API Gateway
################################################

output "apigateway_dns" {
  value = "${aws_instance.apigateway.*.private_dns}"
}

resource "aws_route53_record" "apigateway-a-record" {
    count = "${lookup(var.solution_enable, "apigateway") == "true" ? var.instancecount_apigateway : 0}"

    zone_id = "${data.aws_route53_zone.main-internal.zone_id}"
    name = "apigateway${count.index+1}.${data.aws_route53_zone.main-internal.name}"
    type = "A"
    ttl  = 300
    records = [
        "${element(aws_instance.apigateway.*.private_ip,count.index)}"
    ]
}

//Create the private node general userdata script.
data "template_file" "setup-apigateway" {
  template = "${file("./helper_scripts/setup-private-node.sh")}"
  vars {
    availability_zone = "${data.aws_subnet.COMMON_WEB.0.availability_zone}"
  }
}

resource "aws_instance" "apigateway" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? var.instancecount_apigateway : 0}"

  ami                 = "${local.base_ami_linux}"
  instance_type       = "${var.instancesize_apigateway}"
  subnet_id           = "${data.aws_subnet.COMMON_WEB.*.id[count.index]}"
  key_name            = "${local.awskeypair_internal_node}"
  user_data           = "${data.template_file.setup-apigateway.rendered}"
  associate_public_ip_address = "false"

  # Storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 30
    volume_type = "standard"
  }

  vpc_security_group_ids = [
    "${local.common_secgroups}",
    "${list(
      aws_security_group.apigateway.id
    )}"
  ]

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    local.common_instance_tags,
    map(
      "Name", "${local.name_prefix}-apigateway-${data.aws_subnet.COMMON_WEB.*.availability_zone[count.index]}",
      "az", "${data.aws_subnet.COMMON_WEB.*.availability_zone[count.index]}"
    )
  )}"
}

################ Load Balancer

resource "aws_lb_target_group_attachment" "apigateway-ui" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? var.instancecount_apigateway : 0}"
  
  target_group_arn = "${aws_lb_target_group.apigateway-ui.arn}"
  target_id        = "${element(aws_instance.apigateway.*.id, count.index)}"
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway-ui" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? 1 : 0}"
  
  name     = "${local.name_prefix_unique_short}-apigateway-ui-tg"
  port     = 9072
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.main.id}"
  slow_start = 100
  deregistration_delay = 300

  stickiness {
    enabled = true
    type = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path = "/apigatewayui/login"
    protocol = "HTTP"
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-apigateway-ui-tg"
    )
  )}"
}

resource "aws_alb_listener_rule" "apigateway-ui" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? 1 : 0}"
  
  listener_arn = "${data.aws_lb_listener.main-public-alb-https.arn}"
  
  action {
    target_group_arn = "${aws_lb_target_group.apigateway-ui.arn}"
    type = "forward"
  }

  condition {
    host_header {
      values = ["${local.name_prefix}-apigateway-ui.${local.dns_main_external_apex}"]
    }
  }
}

resource "aws_lb_target_group_attachment" "apigateway-runtime" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? var.instancecount_apigateway : 0}"
  
  target_group_arn = "${aws_lb_target_group.apigateway-runtime.arn}"
  target_id        = "${element(aws_instance.apigateway.*.id, count.index)}"
}

#create a target group for the http reverse proxy instances
resource "aws_lb_target_group" "apigateway-runtime" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? 1 : 0}"
  
  name     = "${local.name_prefix_unique_short}-apigateway-runtime-tg"
  port     = 5555
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.main.id}"
  slow_start = 100
  deregistration_delay = 300

  stickiness {
    enabled = true
    type = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path = "/invoke/wm.server/ping"
    protocol = "HTTP"
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-apigateway-runtime-tg"
    )
  )}"
}

resource "aws_alb_listener_rule" "apigateway-runtime" {
  count = "${lookup(var.solution_enable, "apigateway") == "true" ? 1 : 0}"
  
  listener_arn = "${data.aws_lb_listener.main-public-alb-https.arn}"
  
  action {
    target_group_arn = "${aws_lb_target_group.apigateway-runtime.arn}"
    type = "forward"
  }
  
  condition {
    host_header {
      values = ["${local.name_prefix}-apigateway-runtime.${local.dns_main_external_apex}"]
    }
  }
}