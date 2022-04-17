#!/usr/bin/env bash

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ];then
    BASEDIR=$(dirname "$0")/../..
echo "BASEDIR @: \"${BASEDIR}\""
fi

. ${BASEDIR}/scripts/common.sh

vm_name=${VM_NAME}
username=${SUDO_USER}

vbox_dir="/etc/vbox"

prepare_vbox_autostart_cfg() {
    usermod -aG vboxusers $username
    # prepare directory
    local AUTOSTART_VM_CFG_FILE="${vbox_dir}/autostartvm.cfg"
    echo "  prepare virtualbox config dir: ${vbox_dir}"
    if [[ ! -d ${vbox_dir} ]]; then
        mkdir ${vbox_dir}
    fi
    chgrp vboxusers ${vbox_dir}
    chmod g+w ${vbox_dir}
    chmod +t ${vbox_dir}

    # Configure VirtualBox Autostart Service
    echo "  prepare virtualbox autostart config file: /etc/default/virtualbox"
    cp $BASEDIR/files/host/virtualbox /etc/default/virtualbox
    cp $BASEDIR/files/host/autostartvm.cfg ${AUTOSTART_VM_CFG_FILE}
    sed -i "s|HOST_USER|${username}|g" ${AUTOSTART_VM_CFG_FILE}
}

make_vm_autostart() {
    # Enable Virtual Machine Autostart
    autostart_command="VBoxManage setproperty autostartdbpath ${vbox_dir}"
    echo "  RUN COMMAND for autostart vbox: \"${autostart_command}\""
    runuser -l ${username} -c 'VBoxManage setproperty autostartdbpath /etc/vbox/'

    autostart_command="VBoxManage modifyvm ${vm_name} --autostart-enabled on"
    echo "  RUN COMMAND for autostart vm: \"${autostart_command}\""
    runuser -l ${username} -c "${autostart_command}"

    echo "  Restart service: vboxautostart-service"
    systemctl restart vboxautostart-service
}

main() {
    print_block_header "MAKE VM AUTOSTART"
    . $BASEDIR/config.ini
    expand_net_vars
    check_if_running_as_root
    
    chmod +x $BASEDIR/scripts/host/*.sh
    print_env
    echo "Setup gateway proxy by start ${username}'s virtualbox vm \"${vm_name}\""
    prepare_vbox_autostart_cfg
    make_vm_autostart
    echo "Setup gateway proxy: Done"
    print_block_footer "MAKE VM AUTOSTART DONE"
}

main "$@"