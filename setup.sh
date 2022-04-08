#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
echo "RUN SETUP under dir: ${BASEDIR}"

. $BASEDIR/scripts/common.sh

username=`id -u -n`
sudoer=${SUDO_USER}
echo "user: \"${username}\", sudoer: \"${sudoer}\""
if [ "${sudoer}" != "" ] ; then
    echo "[ERROR] should run as normal user."
    exit 1
fi

if [[ -f "~/.ssh/id_rsa" ]] ; then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa
fi

do_install_vm() {
    pushd $BASEDIR
        echo "RUN: destroy old vm (if exists)"
        # sudo -u ${username} 'vagrant destroy -f'
        vagrant destroy -f

        echo "RUN: setup vm"
        # /bin/su -c  './setup_vm.sh' ${username}
        ./setup_vm.sh
    popd
}

do_setup_autostart() {
    pushd $BASEDIR
        echo "RUN: shutdown vm"
        # runuser -l ${username} -c 'vagrant halt'
        vagrant halt
    popd

    echo "RUN: make vm auto start on host"
    sudo $BASEDIR/setup_vm_auto_start.sh

    pushd $BASEDIR
        echo "RUN: start vm"
        # runuser -l ${username} -c 'vagrant up'
        vagrant up
    popd
}

ask_and_do_setup_autostart() {
    while true
    do
        read -r -p "Make the vm startup on boot? (Y/n):" input
        case $input in
            [yY][eE][sS]|[yY])
                do_setup_autostart
                exit 0
                ;;
            [nN][oO]|[nN])
                echo "Done"
                exit 0
                ;;
            *)
                echo "Invalid input..."
                ;;
        esac
    done
}

do_install_vm
ask_and_do_setup_autostart
