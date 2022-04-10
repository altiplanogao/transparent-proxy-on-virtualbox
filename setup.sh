#!/usr/bin/env bash
# set -o errexit

echo "BASEDIR @: \"${BASEDIR}\""

BASEDIR=$(dirname "$0")
echo "RUN SETUP under dir: ${BASEDIR}"

. $BASEDIR/scripts/host/utils.sh
. $BASEDIR/scripts/common.sh

should_run_as_normal_user() {
    username=`id -u -n`
    sudoer=${SUDO_USER}
    echo "script user: \"${username}\", sudoer: \"${sudoer}\""
    if [ "${sudoer}" != "" ] ; then
        echo "[ERROR] should run as normal user."
        exit 1
    fi

    if [[ -f "~/.ssh/id_rsa" ]] ; then
        ssh-keygen -t rsa -f ~/.ssh/id_rsa
    fi
}

do_install_vm() {
    pushd $BASEDIR

        echo "RUN: destroy old vm (if exists)"
        vagrant destroy -f

        echo "RUN: setup vm"
        download_v2ray
        download_fhs_install_v2ray
        fill_templates

        vagrant up
    popd
}

do_setup_autostart() {
    vagrant_env_prepare
    pushd $BASEDIR
        echo "RUN: shutdown vm"
        # runuser -l ${username} -c 'vagrant halt'
        vagrant halt
    popd

    echo "RUN: make vm auto start on host"
    sudo -E $BASEDIR/scripts/host/make_vm_auto_start.sh

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

should_run_as_normal_user
expand_config
prepare_vagrant_params
vagrant_env_prepare

do_install_vm
ask_and_do_setup_autostart
