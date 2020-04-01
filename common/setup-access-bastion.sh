#!/usr/bin/env bash

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/.."

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

SETENV_CLOUDBASE_PATH=$BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh
if [ ! -f $SETENV_CLOUDBASE_PATH ]; then
    echo "error: file $SETENV_CLOUDBASE_PATH does not exist...Please make sure you applied (or please re-apply) the cloud-base terraform project...exiting!"
    exit 2;
fi

if [ -f $SETENV_CLOUDBASE_PATH ]; then
    . $SETENV_CLOUDBASE_PATH
fi

if [ ! -f $BASTION_SSH_PRIV_KEY_PATH ]; then
    echo "error: file $BASTION_SSH_PRIV_KEY_PATH does not exist...exiting!"
    exit 2;
fi

if [ ! -f $INTERNAL_SSH_PRIV_KEY_PATH ]; then
    echo "error: file $INTERNAL_SSH_PRIV_KEY_PATH does not exist...exiting!"
    exit 2;
fi

if [ "x$BASTION_SSH_HOST" = "x" ]; then
    echo "error: variable BASTION_SSH_HOST does not exist and is required...exiting!"
    exit 2;
fi

if [ "x$BASTION_SSH_USER" = "x" ]; then
    echo "error: variable BASTION_SSH_USER does not exist and is required...exiting!"
    exit 2;
fi

##copying the key to ther bastion
scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $INTERNAL_SSH_PRIV_KEY_PATH $BASTION_SSH_USER@$BASTION_SSH_HOST:~/.ssh/id_rsa
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST "chmod 600 ~/.ssh/id_rsa"
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST "ls -al ~/.ssh/"

##copying the setup management server script to the bastion
SETENV_MANAGEMENT_PATH=$BASEDIR/common/cloud-base/tfexpanded/setenv-mgt.sh
if [ ! -f $SETENV_MANAGEMENT_PATH ]; then
    echo "error: file $SETENV_MANAGEMENT_PATH does not exist...Please make sure you ran the cloud-management terraform project...exiting!"
    exit 2;
fi

if [ -f $SETENV_MANAGEMENT_PATH ]; then
    scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $SETENV_MANAGEMENT_PATH $BASTION_SSH_USER@$BASTION_SSH_HOST:~/
fi

if [ -f $BASEDIR/common/setup-access-management.sh ]; then
    scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $BASEDIR/common/setup-access-management.sh $BASTION_SSH_USER@$BASTION_SSH_HOST:~/setup-access-management.sh
    
    ## execute the setup access management
    ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST "/bin/bash ./setup-access-management.sh"
fi

if [ -f $BASEDIR/common/ssh-to-management.sh ]; then
    scp $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH $BASEDIR/common/ssh-to-management.sh $BASTION_SSH_USER@$BASTION_SSH_HOST:~/ssh-to-management.sh
    ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST "chmod 700 ~/ssh-to-management.sh"
fi