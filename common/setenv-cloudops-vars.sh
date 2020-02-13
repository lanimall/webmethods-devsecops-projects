#!/bin/sh

export TF_VAR_project_owners="YOUR NAME"
export TF_VAR_project_organization="YOUR ORGANIZATION"
export TF_VAR_region="VALID AWS REGION"
export TF_VAR_cloud_profile="AWS AUTH PROFILE NAME"
export TF_VAR_project_name="YOUR PROJECT NAME"

export TF_VAR_resources_external_dns_apex="devsecopsdemo.YOUR_TEST_DOMAIN.COM"
export TF_VAR_resources_internal_dns_apex="devsecopsdemo.YOUR_TEST_DOMAIN.local"
export TF_VAR_bastion_publickey_path="~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/sshkey_id_rsa_bastion.pub"
export TF_VAR_internalnode_publickey_path="~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/sshkey_id_rsa_internalnode.pub"
export TF_VAR_lb_ssl_cert_key="~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/ssl-devsecops-YOUR_TEST_DOMAIN.key"
export TF_VAR_lb_ssl_cert_pub="~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/ssl-devsecops-YOUR_TEST_DOMAIN.crt"
export TF_VAR_lb_ssl_cert_ca="~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/ssl-devsecops-YOUR_TEST_DOMAIN-ca.crt"