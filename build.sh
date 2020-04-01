#!/usr/bin/env bash

set -e

THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR"

BUILD_DIR="$BASEDIR/build"
COMMON_DIR="$BASEDIR/common"
COMMON_ANSIBLE="$COMMON_DIR/webmethods-ansible/"
COMMON_SAGCCE="$COMMON_DIR/webmethods-cce/"
COMMON_CLOUD_BASE_EXPANDED="$COMMON_DIR/cloud-base/tfexpanded"
COMMON_CLOUD_BASE_INVENTORY="$COMMON_CLOUD_BASE_EXPANDED/inventory-ansible"

BUILD_COMMON_ANSIBLE="$BUILD_DIR/webmethods-ansible/"
BUILD_COMMON_CCE="$BUILD_DIR/webmethods-cce/"

##create build directory if does not exist
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

##remove the content in the build directory
if [ -d $BUILD_DIR ]; then
    rm -Rf $BUILD_DIR/*
fi

##Assemble solutions
rsync -arvz --exclude static_* --delete $COMMON_ANSIBLE $BUILD_COMMON_ANSIBLE
rsync -arvz --exclude static_* --delete $COMMON_SAGCCE $BUILD_COMMON_CCE

## + copy the expanded inventory files
if [ -f $COMMON_CLOUD_BASE_INVENTORY ]; then
    cp $COMMON_CLOUD_BASE_INVENTORY $BUILD_COMMON_ANSIBLE/inventory/ansible-inventory-cloud-base
fi

### copy various helper scripts
if [ ! -d $BUILD_DIR/scripts ]; then
    mkdir -p $BUILD_DIR/scripts
fi
rsync -arvz --delete $COMMON_DIR/scripts/ $BUILD_DIR/scripts/

## + copy the expanded script file for s3
if [ -f $COMMON_CLOUD_BASE_EXPANDED/setenv-s3.sh ]; then
    cp $COMMON_CLOUD_BASE_EXPANDED/setenv-s3.sh $BUILD_DIR/scripts/
fi

### copy the sync to management items
if [ -f $COMMON_CLOUD_MGT_EXPANDED/setenv-mgt.sh ]; then
    cp $COMMON_CLOUD_MGT_EXPANDED/setenv-mgt.sh $BUILD_DIR/
fi

if [ -f $BASEDIR/sync-to-management.sh ]; then
    cp $BASEDIR/sync-to-management.sh $BUILD_DIR/
fi

### build the sub projects
if [ -f $BASEDIR/stacks/stack0_command_central/build.sh ]; then
    /bin/bash $BASEDIR/stacks/stack0_command_central/build.sh
fi

if [ -f $BASEDIR/stacks/stack01-apimgt-simple/build.sh ]; then
    /bin/bash $BASEDIR/stacks/stack01-apimgt-simple/build.sh
fi

if [ -f $BASEDIR/stacks/stack02-integration-simple/build.sh ]; then
    /bin/bash $BASEDIR/stacks/stack02-integration-simple/build.sh
fi