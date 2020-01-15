#!/usr/bin/env bash

##some vars for the CLI interactions
export BASTION_SSH_HOST="${bastion_public_ip}"
export BASTION_SSH_USER="${bastion_user}"

##some vars for the other terraform scripts
export TF_VAR_base_region="${region}"
export TF_VAR_base_cloud_profile="${cloud_profile}"
export TF_VAR_base_main_vpc_id="${main_vpc_id}"
export TF_VAR_base_main_bastion_private_ip="${main_bastion_private_ip}"
export TF_VAR_base_main_security_group_common_internal_id="${main_security_group_common-internal_id}"
export TF_VAR_base_internalnode_key_name="${internalnode_key_name}"
export TF_VAR_base_resources_internal_dns_zoneid="${resources_internal_dns_zoneid}"
export TF_VAR_base_resources_external_dns_zoneid="${resources_external_dns_zoneid}"
export TF_VAR_base_main_public_alb_id="${main_public_alb_id}"
export TF_VAR_base_main_public_alb_https_id="${main_public_alb_https_id}"
export TF_VAR_base_subnet_shortname_dmz="${subnet_shortname_dmz}"
export TF_VAR_base_subnet_shortname_web="${subnet_shortname_web}"
export TF_VAR_base_subnet_shortname_apps="${subnet_shortname_apps}"
export TF_VAR_base_subnet_shortname_data="${subnet_shortname_data}"
export TF_VAR_base_subnet_shortname_management="${subnet_shortname_management}"
export TF_VAR_policy_sagcontent_s3_readwrite_arn="${policy_sagcontent_s3_readwrite_arn}"