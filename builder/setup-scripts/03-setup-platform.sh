#!/bin/bash -xe

. $BUILDER_DIR/CONFIG

apt install -y wget tree git

# Load the systemd config files
sudo systemctl daemon-reload

echo "Creating base directories for platform."
mkdir -p $BEANSTALK_DIR/deploy/appsource/
mkdir -p /var/app/staging
mkdir -p /var/app/current
mkdir -p /var/log/nginx/healthd/
chown www-data /var/log/nginx/healthd/

mkdir -p $CONTAINER_CONFIG_FILE_DIR
