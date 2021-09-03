#!/bin/bash -xe

# https://askubuntu.com/questions/1109934/ssh-server-stops-working-after-reboot-caused-by-missing-var-run-sshd

sed -i -e '/^exit 0/i mkdir -p -m0755 /var/run/sshd && systemctl restart ssh.service' /etc/rc.local
cat /etc/rc.local
sed -i -e 's#/var##g' /usr/lib/tmpfiles.d/sshd.conf
cat /usr/lib/tmpfiles.d/sshd.conf