#!/usr/bin/env bash

set -e

## getting filename without path and extension
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../.."

BUILD_DIR="$BASEDIR/build"
BUILD_DIR_ANSIBLE="$BUILD_DIR/webmethods-ansible"
BUILD_DIR_SAGCCE="$BUILD_DIR/webmethods-cce"
CLOUDOPS_INVENTORY="$THISDIR/cloudops/tfexpanded/ansible-inventory"
PROJECT_NAME="$THISDIRNAME"

##Assemble solutions
if [ -d $THISDIR/ansible/ ]; then
    rsync -arvz $THISDIR/ansible/ $BUILD_DIR_ANSIBLE/
fi

if [ -d $THISDIR/webmethods-cce/ ]; then
    rsync -arvz $THISDIR/webmethods-cce/ $BUILD_DIR_SAGCCE/
fi

## + copy the expanded inventory files
if [ -f $CLOUDOPS_INVENTORY ]; then
    cp $CLOUDOPS_INVENTORY $BUILD_DIR_ANSIBLE/inventory/$PROJECT_NAME
fi