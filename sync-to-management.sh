#!/usr/bin/env bash

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
MGT_SSH_KEY="$HOME/.ssh/id_rsa"

if [ -f $HOME/setenv-mgt.sh ]; then
    . $HOME/setenv-mgt.sh
fi

if [ ! -f $MGT_SSH_KEY ]; then
    echo "error: file $MGT_SSH_KEY does not exist...exiting!"
    exit 2;
fi

if [ "x$MGT_SSH_HOST" = "x" ]; then
    echo "error: variable MGT_SSH_HOST is required...exiting!"
    exit 2;
fi

if [ "x$MGT_SSH_USER" = "x" ]; then
    echo "error: variable MGT_SSH_USER is required...exiting!"
    exit 2;
fi

##sync to management
rsync -arvz -e "ssh $SSH_OPTS -i $MGT_SSH_KEY" --delete ~/webmethods-provisioning/ $MGT_SSH_USER@$MGT_SSH_HOST:~/webmethods-provisioning/