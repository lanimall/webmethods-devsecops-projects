#!/usr/bin/env bash

set -e

## getting filename without path and extension
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
THISDIRNAME=`basename $THISDIR`
BASEDIR="$THISDIR/../.."
BUILD_DIR="$BASEDIR/build"
CLOUDOPS_EXPANDED="$THISDIR/cloudops/tfexpanded"
PROJECT_NAME="$THISDIRNAME"

## + copy the expanded inventory files
if [ -f $CLOUDOPS_EXPANDED/inventory-ansible ]; then
    cp $CLOUDOPS_EXPANDED/inventory-ansible $BUILD_DIR/webmethods-devops-ansible/inventory/$PROJECT_NAME
fi