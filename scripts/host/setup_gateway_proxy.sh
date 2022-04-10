#!/usr/bin/env bash

# https://kifarunix.com/autostart-virtualbox-vms-on-system-boot-on-linux/

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ];then
    BASEDIR=$(dirname "$0")/../..
    echo "BASEDIR @: \"${BASEDIR}\""
fi

vm_name=${VM_NAME}

AUTOSTART_VM_CFG_FILE="/etc/vbox/autostartvm.cfg"

# setup user
username=${SUDO_USER}
usermod -aG vboxusers $username

echo "Setup gateway proxy by start ${username}'s virtualbox vm \"${vm_name}\""

# prepare directory
vbox_dir="/etc/vbox"
echo "  prepare virtualbox config dir: ${vbox_dir}"
if [[ ! -d ${vbox_dir} ]]; then
    mkdir ${vbox_dir}
fi
chgrp vboxusers ${vbox_dir}
chmod g+w ${vbox_dir}
chmod +t ${vbox_dir}

# Configure VirtualBox Autostart Service
echo "  prepare virtualbox autostart config file: /etc/default/virtualbox"
cp $BASEDIR/templates/host/virtualbox.tpl /etc/default/virtualbox
cp $BASEDIR/templates/host/autostartvm.cfg.tpl ${AUTOSTART_VM_CFG_FILE}
sed -i "s|HOST_USER|${username}|g" ${AUTOSTART_VM_CFG_FILE}

# Enable Virtual Machine Autostart
autostart_command="VBoxManage setproperty autostartdbpath /etc/vbox/"
echo "  RUN COMMAND for autostart vbox: \"${autostart_command}\""
runuser -l ${username} -c 'VBoxManage setproperty autostartdbpath /etc/vbox/'

autostart_command="VBoxManage modifyvm ${vm_name} --autostart-enabled on"
echo "  RUN COMMAND for autostart vm: \"${autostart_command}\""
runuser -l ${username} -c "${autostart_command}"

echo "  Restart service: vboxautostart-service"
systemctl restart vboxautostart-service

echo "Setup gateway proxy: Done"