#!/usr/bin/env bash

BASTION_SSH_KEY="$HOME/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base/sshkey_id_rsa_bastion"

if [ -f ./common/cloud-base/tfexpanded/setenv-base.sh ]; then
    . ./common/cloud-base/tfexpanded/setenv-base.sh
fi

if [ "x$BASTION_SSH_KEY" = "x" ]; then
    echo "error: variable BASTION_SSH_KEY is required...exiting!"
    exit 2;
fi

if [ ! -f $BASTION_SSH_KEY ]; then
    echo "error: file $BASTION_SSH_KEY does not exist...exiting!"
    exit 2;
fi

if [ "x$BASTION_SSH_HOST" = "x" ]; then
    echo "error: variable BASTION_SSH_HOST is required...exiting!"
    exit 2;
fi

if [ "x$BASTION_SSH_USER" = "x" ]; then
    echo "error: variable BASTION_SSH_USER is required...exiting!"
    exit 2;
fi

##rebuild project
/bin/sh build.sh

##sync built project
echo "Sending files to $BASTION_SSH_USER@$BASTION_SSH_HOST..."
rsync -arvz -e "ssh -i $BASTION_SSH_KEY" --delete ./build/ $BASTION_SSH_USER@$BASTION_SSH_HOST:~/webmethods-provisioning/