#!/usr/bin/env bash

set -e

BUCKET_NAME=owcs-infrastructure
LOCAL_DIR=/opt/softwareag_images/
BUCKET_URI="s3://$BUCKET_NAME/sag/images/"
export PATH=$PATH:~/.virtualenvs/awscli/bin/

##create folder
CURRENT_USER=`id -nu`
if [ ! -d $LOCAL_DIR ]; then
    sudo mkdir -p $LOCAL_DIR
    sudo chown -Rf $CURRENT_USER:$CURRENT_USER $LOCAL_DIR/
fi

# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $LOCAL_DIR