#!/bin/bash -xe

. /etc/application-platform/platform.config

rm -rf $LIVE_DIR
mv $STAGING_DIR $LIVE_DIR
