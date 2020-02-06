#!/usr/bin/env bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/.."

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
if [ -f $BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh ]; then
    . $BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh
fi

BASTION_SSH_KEY=$WEBMETHODS_KEY_PATH/sshkey_id_rsa_bastion

if [ "x$WEBMETHODS_KEY_PATH" = "x" ]; then
    echo "error: variable WEBMETHODS_KEY_PATH is required...exiting!"
    echo "For info: this variable should be the path where the SSH private keys for bastion and internal nodes can be found."
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

##copying the key to ther bastion
scp $SSH_OPTS -i $BASTION_SSH_KEY $WEBMETHODS_KEY_PATH/sshkey_id_rsa_internalnode $BASTION_SSH_USER@$BASTION_SSH_HOST:~/.ssh/id_rsa
ssh $SSH_OPTS -i $BASTION_SSH_KEY -A $BASTION_SSH_USER@$BASTION_SSH_HOST "chmod 600 ~/.ssh/id_rsa"
ssh $SSH_OPTS -i $BASTION_SSH_KEY -A $BASTION_SSH_USER@$BASTION_SSH_HOST "ls -al ~/.ssh/"

##copying the setup management server script to the bastion
scp $SSH_OPTS -i $BASTION_SSH_KEY $BASEDIR/common/cloud-management/tfexpanded/setenv-mgt.sh $BASTION_SSH_USER@$BASTION_SSH_HOST:~/
scp $SSH_OPTS -i $BASTION_SSH_KEY $BASEDIR/common/setup-access-management.sh $BASTION_SSH_USER@$BASTION_SSH_HOST:~/

## execute the setup access management
ssh $SSH_OPTS -i $BASTION_SSH_KEY -A $BASTION_SSH_USER@$BASTION_SSH_HOST "/bin/bash ./setup-access-management.sh"