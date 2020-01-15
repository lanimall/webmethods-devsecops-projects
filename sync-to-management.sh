#!/usr/bin/env bash

MGT_SSH_KEY="$HOME/.ssh/id_rsa"

if [ -f setenv-mgt.sh ]; then
    . setenv-mgt.sh
fi

if [ "x$MGT_SSH_KEY" = "x" ]; then
    echo "error: variable MGT_SSH_KEY is required...exiting!"
    exit 2;
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
rsync -arvz -e "ssh -i $MGT_SSH_KEY" --delete ~/webmethods-provisioning/ $MGT_SSH_USER@$MGT_SSH_HOST:~/webmethods-provisioning/