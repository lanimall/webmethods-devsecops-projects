output "vpccid" {
  value = aws_vpc.main.id
}

output "ami_linux" {
  value = local.base_ami_linux
}

output "amiuser_linux" {
  value = local.base_ami_linux_user
}

output "ami_windows" {
  value = local.base_ami_windows
}

output "amiuser_windows" {
  value = local.base_ami_windows_user
}

output "aws_key_pair_internalnode" {
  value = aws_key_pair.internalnode.id
}

output "name_prefix_long" {
  value = local.name_prefix_long
}

output "name_prefix_short" {
  value = local.name_prefix_short
}

output "name_prefix_unique_short" {
  value = local.name_prefix_unique_short
}

data "template_file" "setenv-base" {
  template = file("${path.cwd}/helper_scripts/setenv-base.sh")

  vars = {
    region                                 = var.region
    cloud_profile                          = var.cloud_profile
    main_vpc_id                            = aws_vpc.main.id
    name_prefix_unique_short               = local.name_prefix_unique_short
    name_prefix_short                      = local.name_prefix_short
    name_prefix_long                       = local.name_prefix_long
    main_bastion_private_ip                = aws_instance.bastion-linux[0].private_ip
    main_security_group_common-internal_id = aws_security_group.common-internal.id
    internalnode_key_name                  = aws_key_pair.internalnode.id
    resources_external_dns_zoneid          = aws_route53_zone.main-external.id
    resources_external_dns_apex            = local.dns_main_external_apex
    resources_internal_dns_zoneid          = aws_route53_zone.main-internal.id
    resources_internal_dns_apex            = local.dns_main_internal_apex
    main_public_alb_dns_name               = aws_lb.main-public-alb.dns_name
    main_public_alb_id                     = aws_lb.main-public-alb.id
    main_public_alb_https_id               = aws_lb_listener.main-public-alb-https.id
    subnet_shortname_dmz                   = var.subnet_shortname_dmz
    subnet_shortname_web                   = var.subnet_shortname_web
    subnet_shortname_apps                  = var.subnet_shortname_apps
    subnet_shortname_data                  = var.subnet_shortname_data
    subnet_shortname_management            = var.subnet_shortname_management
    bastion_public_ip                      = aws_instance.bastion-linux[0].public_ip
    bastion_user                           = local.base_ami_linux_user
    policy_sagcontent_s3_readwrite_arn     = aws_iam_policy.sagcontent-s3-readwrite.arn
  }
}

resource "local_file" "setenv-base" {
  content  = data.template_file.setenv-base.rendered
  filename = "${path.cwd}/tfexpanded/setenv-base.sh"
}

