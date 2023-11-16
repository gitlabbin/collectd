#!/bin/bash

set -ex
shopt -s expand_aliases

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VER=`cat VERSION`
BUILD_NUMBER=2
INSIGHT_VERSION="${VER}-${BUILD_NUMBER}"
debugoutput="insights-collectd-debug-$TARGET_PLATFORM-${INSIGHT_VERSION}.tar.gz"
output="insights-collectd-$TARGET_PLATFORM-${INSIGHT_VERSION}.tar.gz"
output_tar=$(basename $output .gz)

image=collectd-dse-bundle-$TARGET_PLATFORM

cd ../; docker build -t $image \
  --platform linux/$TARGET_PLATFORM \
  --build-arg insight_version=${INSIGHT_VERSION} . 

cid=$(docker create $image true)
trap "docker rm -f $cid; rm -f $output_tar" EXIT

# for macos we using gnu tar, you may need install it `brew install gnu-tar; alias tar=gtar`
[ "$TARGET_PLATFORM" = "arm64" ] && alias tar=gtar
docker export $cid | tar --delete 'dev' 'proc' 'etc' 'sys' 'collectd-symbols' | gzip -f - > $output
docker export $cid | tar --delete 'dev' 'proc' 'etc' 'sys' 'collectd' | gzip -f - > $debugoutput
