###################### variables from base

data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = "${path.cwd}/../../../common/cloud-base/terraform.tfstate"
  }
}

locals {
  base_vpc_id = data.terraform_remote_state.base.outputs.vpc_id
  base_name_prefix_unique_short=data.terraform_remote_state.base.outputs.name_prefix_unique_short
  base_name_prefix_long=data.terraform_remote_state.base.outputs.name_prefix_long
  base_main_bastion_private_ip=data.terraform_remote_state.base.outputs.main_bastion_private_ip
  base_main_security_group_common_internal_id=data.terraform_remote_state.base.outputs.main_security_group_common_internal_id
  base_internalnode_key_name=data.terraform_remote_state.base.outputs.internalnode_key_name
  base_resources_internal_dns_zoneid=data.terraform_remote_state.base.outputs.resources_internal_dns_zoneid
  base_resources_internal_dns_apex=data.terraform_remote_state.base.outputs.resources_internal_dns_apex
  base_resources_external_dns_zoneid=data.terraform_remote_state.base.outputs.resources_external_dns_zoneid
  base_resources_external_dns_apex=data.terraform_remote_state.base.outputs.resources_external_dns_apex
  base_main_public_alb_dns_name=data.terraform_remote_state.base.outputs.main_public_alb_dns_name
  base_main_public_alb_id=data.terraform_remote_state.base.outputs.main_public_alb_id
  base_main_public_alb_https_id=data.terraform_remote_state.base.outputs.main_public_alb_https_id
  base_subnet_shortname_dmz=data.terraform_remote_state.base.outputs.subnet_shortname_dmz
  base_subnet_shortname_web=data.terraform_remote_state.base.outputs.subnet_shortname_web
  base_subnet_shortname_apps=data.terraform_remote_state.base.outputs.subnet_shortname_apps
  base_subnet_shortname_data=data.terraform_remote_state.base.outputs.subnet_shortname_data
  base_subnet_shortname_management=data.terraform_remote_state.base.outputs.subnet_shortname_management
  base_policy_sagcontent_s3_readwrite_arn=data.terraform_remote_state.base.outputs.policy_sagcontent_s3_readwrite_arn
}