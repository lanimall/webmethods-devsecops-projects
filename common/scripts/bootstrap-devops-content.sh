#!/usr/bin/env bash

set -e

##TODO: this should come from the terraform data...
BUCKET_NAME=ac216fa6-main
BUCKET_PREFIX=sagdemo-master

LOCAL_DIR=$HOME/devops_content/
BUCKET_URI="s3://$BUCKET_NAME/$BUCKET_PREFIX/devops_content/"

if [ -f $HOME/setenv.sh ]; then
    . $HOME/setenv.sh
fi

##make the ssh key a default one
if [ -f $HOME/.ssh/sshkey_id_rsa_internalnode ] && [ ! -f $HOME/.ssh/id_rsa ] ; then
    echo "Linking the custom ssh key to the default $HOME/.ssh/id_rsa"
    ln -s $HOME/.ssh/sshkey_id_rsa_internalnode $HOME/.ssh/id_rsa
fi

##add SSH folder to automation_user home
if [ ! -d $LOCAL_DIR ]; then
    mkdir -p $LOCAL_DIR
fi

# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $LOCAL_DIR

echo "Content should now be in $LOCAL_DIR"