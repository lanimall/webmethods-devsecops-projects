#!/usr/bin/env bash

SSH_KEY="./common/cloud-base/helper_scripts/sshkey_id_rsa_bastion"
SSH_USER="centos"
SSH_HOST="18.222.116.208"

##sync build project
rsync -arvz -e "ssh -i $SSH_KEY" --delete ./build/ $SSH_USER@$SSH_HOST:~/webmethods-provisioning/