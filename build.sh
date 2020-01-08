#!/usr/bin/env bash

set -e

BUILD_DIR="./build"

COMMON_DIR="./common"
COMMON_INTERNAL_NODE_SSH_KEY="$COMMON_DIR/cloud-base/helper_scripts/sshkey_id_rsa_internalnode"
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

### + copy SSH key
if [ -f $COMMON_INTERNAL_NODE_SSH_KEY ]; then
    if [ ! -d $BUILD_DIR/.ssh ]; then
        mkdir -p $BUILD_DIR/.ssh
    fi
    cp $COMMON_INTERNAL_NODE_SSH_KEY $BUILD_DIR/.ssh/
fi

## + copy the expanded inventory files
if [ -f $COMMON_CLOUD_BASE_EXPANDED/inventory-ansible ]; then
    cp $COMMON_CLOUD_BASE_EXPANDED/inventory-ansible $BUILD_DIR/webmethods-devops-ansible/inventory/inventory-ansible-base
fi

if [ -f $COMMON_CLOUD_MGT_EXPANDED/inventory-ansible ]; then
    cp $COMMON_CLOUD_MGT_EXPANDED/inventory-ansible $BUILD_DIR/webmethods-devops-ansible/inventory/inventory-ansible-management
fi

### copy various helper scripts
if [ ! -d $BUILD_DIR/scripts ]; then
    mkdir -p $BUILD_DIR/scripts
fi

if [ -f $COMMON_CLOUD_MGT_EXPANDED/sync-to-management.sh ]; then
    cp $COMMON_CLOUD_MGT_EXPANDED/sync-to-management.sh $BUILD_DIR/
fi

cp $COMMON_DIR/scripts/*.sh $BUILD_DIR/scripts/