#!/usr/bin/env bash

set -e

## getting filename without path and extension
THIS=`basename $0`
THIS_NOEXT="${THIS%.*}"
THISDIR=`dirname $0`; THISDIR=`cd $THISDIR;pwd`
BASEDIR="$THISDIR/../.."

BUILD_DIR="$BASEDIR/build"
CLOUDOPS_EXPANDED="$THISDIR/cloudops/tfexpanded"
