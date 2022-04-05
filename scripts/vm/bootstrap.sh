#!/usr/bin/env bash

mv /home/vagrant/vm_templates.resolved /templates.resolved
mv /home/vagrant/package /resources

# set resolved.conf
mv /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bk
cp /templates.resolved/resolved.conf /etc/systemd/resolved.conf

# install v2ray
chmod +x /resources/fhs-install-v2ray/*.sh
echo '' | /resources/fhs-install-v2ray/install-release.sh -l /resources/v2ray-linux-64.zip

# use config file
cp /templates.resolved/config.client /usr/local/etc/v2ray/config.json

# enable service
systemctl enable v2ray
systemctl start v2ray
