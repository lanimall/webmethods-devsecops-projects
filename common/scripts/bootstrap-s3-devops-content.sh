#!/usr/bin/env bash

set -e

## getting current filename and basedir
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/.."

if [ -f $BASEDIR/scripts/setenv-s3.sh ]; then
    . $BASEDIR/scripts/setenv-s3.sh
fi

if [ "x$S3_BUCKET_NAME" = "x" ]; then
    echo "error: variable S3_BUCKET_NAME does not exist and is required...exiting!"
    exit 2;
fi

if [ "x$S3_BUCKET_PREFIX" = "x" ]; then
    echo "error: variable S3_BUCKET_PREFIX does not exist and is required...exiting!"
    exit 2;
fi

S3_BUCKET_URI="s3://$S3_BUCKET_NAME/$S3_BUCKET_PREFIX/devops_content/"
LOCAL_DIR=$HOME/devops_content/

if [ -f $HOME/setenv.sh ]; then
    . $HOME/setenv.sh
fi

##create folder
CURRENT_USER=`id -nu`
if [ ! -d $LOCAL_DIR ]; then
    sudo mkdir -p $LOCAL_DIR
    sudo chown -Rf $CURRENT_USER:$CURRENT_USER $LOCAL_DIR/
fi

##make the ssh key a default one
if [ -f $HOME/.ssh/sshkey_id_rsa_internalnode ] && [ ! -f $HOME/.ssh/id_rsa ] ; then
    echo "Linking the custom ssh key to the default $HOME/.ssh/id_rsa"
    ln -s $HOME/.ssh/sshkey_id_rsa_internalnode $HOME/.ssh/id_rsa
fi

# Synchronize the keys from the bucket.
aws s3 sync --delete $S3_BUCKET_URI $LOCAL_DIR

echo "Content should now be in $LOCAL_DIR"