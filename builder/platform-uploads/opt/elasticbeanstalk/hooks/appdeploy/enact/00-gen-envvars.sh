#!/bin/bash

. /etc/application-platform/platform.config

mkdir -p $CONFIG_DIR
rm -f $CONFIG_DIR/envvars.json

$EB_DIR/bin/get-config optionsettings > $CONFIG_DIR/envvars.json
