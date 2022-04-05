#!/usr/bin/env bash

# https://kifarunix.com/autostart-virtualbox-vms-on-system-boot-on-linux/

BASEDIR=$(dirname "$0")
AUTOSTART_VM_CFG_FILE="/etc/vbox/autostartvm.cfg"

# setup user
username=${SUDO_USER}
usermod -aG vboxusers $username

# prepare directory
mkdir /etc/vbox
chgrp vboxusers /etc/vbox
chmod g+w /etc/vbox
chmod +t /etc/vbox

# Configure VirtualBox Autostart Service
cp $BASEDIR/../../templates/host/virtualbox.tpl /etc/default/virtualbox
cp $BASEDIR/../../templates/host/autostartvm.cfg.tpl ${AUTOSTART_VM_CFG_FILE}
sed -i "s|HOST_USER|${username}|g" ${AUTOSTART_VM_CFG_FILE}

# Enable Virtual Machine Autostart
runuser -l ${username} -c 'VBoxManage setproperty autostartdbpath /etc/vbox/'
runuser -l ${username} -c 'VBoxManage modifyvm v2ray-proxy-01 --autostart-enabled on'

systemctl restart vboxautostart-service
