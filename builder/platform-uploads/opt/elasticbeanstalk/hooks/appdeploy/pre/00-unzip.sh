#!/bin/bash

. /etc/application-platform/platform.config

if /opt/elasticbeanstalk/bin/download-source-bundle; then
	rm -rf $STAGING_DIR
	mkdir -p $STAGING_DIR

	# Use "-j" to not create a subdirectory in $STAGING_DIR
	unzip -j -o -d $STAGING_DIR /opt/elasticbeanstalk/deploy/appsource/source_bundle
	rm -rf $STAGING_DIR/.ebextensions
else
	echo "No application version available."
fi
