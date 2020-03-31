##########################
# Load balancers
##########################

output "main-public-alb" {
  value = aws_lb.main-public-alb.dns_name
}

output "main_public_alb_dns_name" {
  value = aws_lb.main-public-alb.dns_name
}

output "main_public_alb_id" {
  value = aws_lb.main-public-alb.id
}

output "main_public_alb_https_id" {
  value = aws_lb_listener.main-public-alb-https.id
}

resource "aws_acm_certificate" "cert" {
  private_key       = file(local.lb_ssl_cert_key)
  certificate_body  = file(local.lb_ssl_cert_pub)
  certificate_chain = file(local.lb_ssl_cert_ca)
}

###### DMZ ###### 

####### Main public app traffic

resource "aws_route53_record" "main-alb-wildcard" {
  zone_id = aws_route53_zone.main-external.zone_id
  name    = "*.${aws_route53_zone.main-external.name}"
  type    = "A"

  alias {
    name                   = aws_lb.main-public-alb.dns_name
    zone_id                = aws_lb.main-public-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "main-public-alb" {
  name               = "${local.name_prefix_short}-main"
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.COMMON_DMZ.*.id
  security_groups = [
    aws_security_group.main-public-alb.id,
  ]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  enable_http2                     = true
  idle_timeout                     = 60

  /*
  access_logs {
    bucket  = "${aws_s3_bucket.webm-ext-app-lb-logs.bucket}"
    prefix  = "main-public"
    enabled = true
  }
  */

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-main-public-alb"
    },
  )
}

resource "aws_lb_listener" "main-public-alb-http" {
  load_balancer_arn = aws_lb.main-public-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "main-public-alb-https" {
  load_balancer_arn = aws_lb.main-public-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.cert.id

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Illegal Access"
      status_code  = "503"
    }
  }
}

