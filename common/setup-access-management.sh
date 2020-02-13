#!/usr/bin/env bash

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
INTERNAL_SSH_KEY="$HOME/.ssh/id_rsa"

if [ -f $HOME/setenv-mgt.sh ]; then
    . $HOME/setenv-mgt.sh
fi

if [ "x$INTERNAL_SSH_KEY" = "x" ]; then
    echo "error: variable INTERNAL_SSH_KEY is required...exiting!"
    exit 2;
fi

if [ ! -f $INTERNAL_SSH_KEY ]; then
    echo "error: file $INTERNAL_SSH_KEY does not exist...exiting!"
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

##copying the key to the management server
scp $SSH_OPTS -i $INTERNAL_SSH_KEY $INTERNAL_SSH_KEY $MGT_SSH_USER@$MGT_SSH_HOST:~/.ssh/id_rsa
ssh $SSH_OPTS -i $INTERNAL_SSH_KEY -A $MGT_SSH_USER@$MGT_SSH_HOST "chmod 600 ~/.ssh/id_rsa"
ssh $SSH_OPTS -i $INTERNAL_SSH_KEY -A $MGT_SSH_USER@$MGT_SSH_HOST "ls -al ~/.ssh/"