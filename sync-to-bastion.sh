#!/usr/bin/env bash

SSH_KEY="./common/cloud-base/helper_scripts/sshkey_id_rsa_bastion"
SSH_USER="centos"

##that's the EIP...
SSH_HOST="18.221.246.64"

##rebuild project
/bin/sh build.sh

##sync built project
rsync -arvz -e "ssh -i $SSH_KEY" --delete ./build/ $SSH_USER@$SSH_HOST:~/webmethods-provisioning/