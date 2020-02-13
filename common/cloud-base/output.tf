output "vpc_id" {
  value = aws_vpc.main.id
}

output "region" {
  value = var.region
}

output "cloud_profile" {
  value = var.cloud_profile
}

output "name_prefix_unique_short" {
  value = local.name_prefix_unique_short
}

output "name_prefix_no_id" {
  value = local.name_prefix_no_id
}

output "name_prefix_long" {
  value = local.name_prefix_long
}

output "main_bastion_private_ip" {
  value = aws_instance.bastion-linux.*.private_ip
}

output "main_security_group_common_internal_id" {
  value = aws_security_group.common-internal.id
}

output "internalnode_key_name" {
  value = aws_key_pair.internalnode.id
}

output "resources_internal_dns_zoneid" {
  value = aws_route53_zone.main-internal.id
}

output "resources_internal_dns_apex" {
  value = local.dns_main_internal_apex
}

output "resources_external_dns_zoneid" {
  value = aws_route53_zone.main-external.id
}

output "resources_external_dns_apex" {
  value = local.dns_main_external_apex
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

output "subnet_shortname_dmz" {
  value = var.subnet_shortname_dmz
}

output "subnet_shortname_web" {
  value = var.subnet_shortname_web
}

output "subnet_shortname_apps" {
  value = var.subnet_shortname_apps
}

output "subnet_shortname_data" {
  value = var.subnet_shortname_data
}

output "subnet_shortname_management" {
  value = var.subnet_shortname_management
}

output "policy_sagcontent_s3_readwrite_arn" {
  value = aws_iam_policy.sagcontent-s3-readwrite.arn
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

data "template_file" "setenv-base" {
  template = file("${path.cwd}/helper_scripts/setenv-base.sh")

  vars = {
    bastion_public_ip      = aws_eip.bastion.0.public_ip
    bastion_user           = local.base_ami_linux_user
    bastion_ssh_publickey_path   = replace(local.awskeypair_bastion_keypath, "~/", "$HOME/")
    bastion_ssh_privatekey_path  = replace(local.awskeypair_bastion_privatekeypath, "~/", "$HOME/")
    internal_ssh_publickey_path  = replace(local.awskeypair_internal_keypath, "~/", "$HOME/")
    internal_ssh_privatekey_path = replace(local.awskeypair_internal_privatekeypath, "~/", "$HOME/")
    s3_bucket_name               = length(aws_s3_bucket.main)>0 ? aws_s3_bucket.main[0].id : "null"
    s3_bucket_prefix             = local.name_prefix_long
  }
}

resource "local_file" "setenv-base" {
  content  = data.template_file.setenv-base.rendered
  filename = "${path.cwd}/tfexpanded/setenv-base.sh"
}

data "template_file" "setenv-s3" {
  template = file("${path.cwd}/helper_scripts/setenv-s3.sh")

  vars = {
    s3_bucket_name               = length(aws_s3_bucket.main)>0 ? aws_s3_bucket.main[0].id : "null"
    s3_bucket_prefix             = local.name_prefix_long
  }
}

resource "local_file" "setenv-s3" {
  content  = data.template_file.setenv-s3.rendered
  filename = "${path.cwd}/tfexpanded/setenv-s3.sh"
}
