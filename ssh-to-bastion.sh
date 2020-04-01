#!/usr/bin/env bash

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR"
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

ssh $SSH_OPTS -i $BASTION_SSH_PRIV_KEY_PATH -A $BASTION_SSH_USER@$BASTION_SSH_HOST