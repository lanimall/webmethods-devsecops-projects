#!/usr/bin/env bash

set -e

##TODO: this should come from the terraform data...
BUCKET_NAME=ac216fa6-main
BUCKET_PREFIX=sagdemo-master

##depending on the size, ideally that path should be a mount point to a larger disk
LOCAL_DIR=/opt/sag_content/
BUCKET_URI="s3://$BUCKET_NAME/$BUCKET_PREFIX/sag_content/"

if [ -f $HOME/setenv.sh ]; then
    . $HOME/setenv.sh
fi

##create folder
CURRENT_USER=`id -nu`
if [ ! -d $LOCAL_DIR ]; then
    sudo mkdir -p $LOCAL_DIR
    sudo chown -Rf $CURRENT_USER:$CURRENT_USER $LOCAL_DIR/
fi

# Synchronize the keys from the bucket.
aws s3 sync --delete $BUCKET_URI $LOCAL_DIR

echo "Content should now be in $LOCAL_DIR"