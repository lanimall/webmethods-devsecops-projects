#!/usr/bin/env bash

set -e

BUILD_DIR="./build"
COMMON_DIR="./common"
COMMON_ANSIBLE="$COMMON_DIR/ansible/"
COMMON_SAGCCE="$COMMON_DIR/sagcce/"

COMMON_CLOUD_BASE_EXPANDED="$COMMON_DIR/cloud-base/tfexpanded"
COMMON_CLOUD_MGT_EXPANDED="$COMMON_DIR/cloud-management/tfexpanded"

##create build directory if does not exist
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

##remove the content in the build directory
if [ -d $BUILD_DIR ]; then
    rm -Rf $BUILD_DIR/*
fi

##Assemble solutions
rsync -arvz --exclude static_* --delete $COMMON_ANSIBLE $BUILD_DIR/webmethods-devops-ansible/
rsync -arvz --exclude static_* --delete $COMMON_SAGCCE $BUILD_DIR/webmethods-devops-sagcce/

## + copy the expanded inventory files
if [ -f $COMMON_CLOUD_BASE_EXPANDED/inventory-ansible.cfg ]; then
    cp $COMMON_CLOUD_BASE_EXPANDED/inventory-ansible.cfg $BUILD_DIR/webmethods-devops-ansible/inventory/inventory-ansible-base.cfg
fi

if [ -f $COMMON_CLOUD_MGT_EXPANDED/inventory-ansible.cfg ]; then
    cp $COMMON_CLOUD_MGT_EXPANDED/inventory-ansible.cfg $BUILD_DIR/webmethods-devops-ansible/inventory/inventory-ansible-management.cfg
fi

### copy various helper scripts
if [ ! -d $BUILD_DIR/scripts ]; then
    mkdir -p $BUILD_DIR/scripts
fi

if [ -f $COMMON_CLOUD_MGT_EXPANDED/sync-to-management.sh ]; then
    cp $COMMON_CLOUD_MGT_EXPANDED/sync-to-management.sh $BUILD_DIR/scripts/
fi

cp $COMMON_DIR/scripts/*.sh $BUILD_DIR/scripts/