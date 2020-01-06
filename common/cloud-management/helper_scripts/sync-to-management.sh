#!/usr/bin/env bash

SSH_KEY="$HOME/.ssh/id_rsa"
SSH_USER="fsanglier"
SSH_HOST="${management1_ip}"

##sync ansible project
rsync -arvz -e "ssh -i $SSH_KEY" --delete ~/webmethods-devops-ansible/ $SSH_USER@$SSH_HOST:~/webmethods-devops-ansible/

##sync wM automation project
rsync -arvz -e "ssh -i $SSH_KEY" --delete ~/webmethods-devops-sagcce/ $SSH_USER@$SSH_HOST:~/webmethods-devops-sagcce/

##copy the scripts
scp -i $SSH_KEY ./*.sh $SSH_USER@$SSH_HOST:~/