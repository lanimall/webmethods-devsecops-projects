#!/usr/bin/env bash

##some vars for the CLI interactions
export BASTION_SSH_HOST="18.191.12.13"
export BASTION_SSH_USER="centos"

export BASTION_SSH_PRIV_KEY_PATH="$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/demoenv/certs/ssh/sshkey_id_rsa_bastion"
export BASTION_SSH_PUB_KEY_PATH="$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/demoenv/certs/ssh/sshkey_id_rsa_bastion.pub"

export INTERNAL_SSH_PRIV_KEY_PATH="$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/demoenv/certs/ssh/sshkey_id_rsa_internalnode"
export INTERNAL_SSH_PUB_KEY_PATH="$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/demoenv/certs/ssh/sshkey_id_rsa_internalnode.pub"

export EXTERNAL_WEB_DOMAIN="devsecops.softwareagdemos.com"