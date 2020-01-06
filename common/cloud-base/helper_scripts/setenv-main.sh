#!/usr/bin/env bash

export TF_VAR_main_vpc_id="${main_vpc_id}"
export TF_VAR_main_bastion_private_ip="${main_bastion_private_ip}"
export TF_VAR_main_security_group_common_internal_id="${main_security_group_common-internal_id}"
export TF_VAR_internalnode_key_name="${internalnode_key_name}"