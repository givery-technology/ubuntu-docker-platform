#!/bin/bash

. /etc/application-platform/platform.config

mkdir -p $CONFIG_DIR
rm -f $CONFIG_DIR/envvars.json

$EB_DIR/bin/get-config optionsettings > $CONFIG_DIR/envvars.json
cat $CONFIG_DIR/envvars.json | jq -r -c '.["aws:elasticbeanstalk:application:environment"] | to_entries | map("\(.key)=\(.value)") | .[]' > /etc/systemd/system/blue.env
cat $CONFIG_DIR/envvars.json | jq -r -c '.["aws:elasticbeanstalk:application:environment"] | to_entries | map("\(.key)=\(.value)") | .[]' > /etc/systemd/system/green.env

sudo systemctl daemon-reload
