#!/usr/bin/env bash

set -e

## getting filename without path and extension
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../.."
BUILD_DIR="$BASEDIR/build"

CLOUDOPS_INVENTORY="$THISDIR/cloudops/outputs/*/ansible-inventory"
PROJECT_NAME="$THISDIRNAME"

##Assemble solutions
if [ -d $THISDIR/ansible/ ]; then
    rsync -arvz $THISDIR/ansible/ $BUILD_DIR/webmethods-ansible/
fi

if [ -d $THISDIR/webmethods-cce/ ]; then
    rsync -arvz $THISDIR/webmethods-cce/ $BUILD_DIR/webmethods-cce/
fi

## + copy the expanded inventory files
if [ -f $CLOUDOPS_INVENTORY ]; then
    cp $CLOUDOPS_INVENTORY $BUILD_DIR/webmethods-ansible/inventory/$PROJECT_NAME
fi