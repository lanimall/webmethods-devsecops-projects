#!/usr/bin/env bash

set -e

BUCKET_NAME=owcs-infrastructure
LOCAL_DIR=$HOME/devops_content/
BUCKET_URI="s3://$BUCKET_NAME/sag/devops/"
export PATH=$PATH:~/.virtualenvs/awscli/bin/

##add SSH folder to automation_user home
if [ ! -d $LOCAL_DIR ]; then
    mkdir $LOCAL_DIR
fi

# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $LOCAL_DIR

# put the key in the right place for use
cp devops_content/keys/sshkey-owcpsagenv-internal.pem ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa