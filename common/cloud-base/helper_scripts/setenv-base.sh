#!/usr/bin/env bash

##some vars for the CLI interactions
export BASTION_SSH_HOST="${bastion_public_ip}"
export BASTION_SSH_USER="${bastion_user}"
export BASTION_SSH_PRIV_KEY_PATH="${bastion_ssh_privatekey_path}"
export BASTION_SSH_PUB_KEY_PATH="${bastion_ssh_publickey_path}"
export INTERNAL_SSH_PRIV_KEY_PATH="${internal_ssh_privatekey_path}"
export INTERNAL_SSH_PUB_KEY_PATH="${internal_ssh_publickey_path}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export S3_BUCKET_PREFIX="${s3_bucket_prefix}"