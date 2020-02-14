#!/usr/bin/env bash

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR"

BUILD_DIR="$BASEDIR/build"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

if [ -f $BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh ]; then
    . $BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh
fi

if [ ! -f $BASTION_SSH_PRIV_KEY_PATH ]; then
    echo "error: file $BASTION_SSH_PRIV_KEY_PATH does not exist...exiting!"
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
rsync -arvz -e "ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH" --delete $BUILD_DIR/ $BASTION_SSH_USER@$BASTION_SSH_HOST:~/webmethods-provisioning/

## execute the sync to management from the bastion
ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST "/bin/bash ~/webmethods-provisioning/sync-to-management.sh"