#!/usr/bin/env bash
set -o errexit

BASEDIR=$(dirname "$0")
PKG_DIR="package"

vm_prefix="v2ray2"

. $BASEDIR/scripts/host/download.sh
. $BASEDIR/scripts/common.sh
. $BASEDIR/scripts/host/handle_resource.sh
. $BASEDIR/scripts/host/vbox_utils.sh

should_run_as_normal_user() {
    username=`id -u -n`
    sudoer=${SUDO_USER}
    echo "script user: \"${username}\", sudoer: \"${sudoer}\""
    if [ "${sudoer}" != "" ] ; then
        echo "[ERROR] should run as normal user."
        exit 1
    fi

    if [[ ! -f ~/.ssh/id_rsa ]] ; then
        ssh-keygen -t rsa -f ~/.ssh/id_rsa
    fi
}

check_required_softwares() {
    if ! ipcalc -v > /dev/null
    then
        echo "[ERROR] ipcalc not found, please install it manually."
        exit
    fi
}

vagrant_env_prepare() {
    VM_NAME="${vm_prefix}-${PROXY_IP//./-}-${PROXY_MODE}"

    PROXY_IP=${PROXY_IP}
    export PROXY_IP
    export BRIDGE_NAME
    export LAN_NETMASK_EXPAND
    export ROUTER_IP
    export VM_NAME
    export PROXY_MODE
}

do_install_vm() {
    pushd $BASEDIR

        echo "RUN: destroy old vm (if exists)"
        vagrant destroy -f

        echo "RUN: setup vm"
        download_v2ray
        download_fhs_install_v2ray

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
    sudo -E $BASEDIR/scripts/host/make_vm_autostart.sh

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

install_local() {
    sudo cp -rf $BASEDIR/vm.resources.suite /resources
    cd /resources
    sudo /resources/bootstrap.sh
}

reinstall_vm() {
    do_install_vm
    ask_and_do_setup_autostart
}

# ===============================================
## Demo function for processing parameters
judgment_parameters() {
    if [[ "$#" -eq '0' ]]; then
        INSTALL_VM='1'
    fi
  while [[ "$#" -gt '0' ]]; do
    case "$1" in
      '--remove')
        if [[ "$#" -gt '1' ]]; then
          echo 'error: Please enter the correct parameters.'
          exit 1
        fi
        REMOVE='1'
        ;;
      '-iv' | '--install-vm')
        if [[ "$#" -gt '1' ]]; then
          echo 'error: Please enter the correct parameters.'
          exit 1
        fi
        INSTALL_VM='1'
        ;;
      '-il' | '--install-local')
        if [[ "$#" -gt '1' ]]; then
          echo 'error: Please enter the correct parameters.'
          exit 1
        fi
        INSTALL_LOCAL='1'
        ;;
      '-c' | '--clean')
        CLEAN='1'
        break
        ;;
      '-g' | '--gen')
        GEN='1'
        break
        ;;
      '-u' | '--up')
        UP='1'
        break
        ;;
      '-d' | '--down')
        DOWN='1'
        break
        ;;
      '-h' | '--help')
        HELP='1'
        break
        ;;
      *)
        echo "$0: unknown option -- -"
        exit 1
        ;;
    esac
    shift
  done
}

# Explanation of parameters in the script
show_help() {
  echo "usage: $0 [--remove | --install-vm | --install-local | -c | -u | -d | -h]"
  echo '  --remove                  Remove installed vm'
  echo '  -iv, --install-vm         Install proxy vm on virtualbox (the default action)'
  echo '  -il, --install-local      Install proxy on local machine'
  echo '  -g, --gen                 Generate script suite'
  echo '  -c, --clean               Remove all installed vm'
  echo '  -u, --up                  Start the vm'
  echo '  -d, --down                Stop the vm'
  echo '  -h, --help                Show help'
  
  exit 0
}

clean_vms() {
    echo "Clean vms start"
    local vmnames=(`vboxmanage list vms | awk '{print $1}' | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`)
    for vm in "${vmnames[@]}"
    do
        echo "  kill and remove: $vm"
        vboxmanage controlvm $vm poweroff
        vboxmanage unregistervm $vm --delete
    done
    echo "Clean vms done"
}

main() {
    judgment_parameters "$@"
    [[ "$HELP" -eq '1' ]] && show_help

    local conf_file=$BASEDIR/config.ini
    if [[ ! -f ${conf_file} ]];then
        echo "${conf_file} missing, please follow \"README.md\" instructions."
        return 0
    fi

    check_required_softwares

    should_run_as_normal_user
    chmod +x . $BASEDIR/vm.resources/scripts/*.sh

    . $BASEDIR/config.ini

    download_v2ray
    download_fhs_install_v2ray

    expand_net_vars
    if [[ "$INSTALL_LOCAL" -eq '1' ]]; then
        install_local
        exit $?
    fi

    if [[ "$CLEAN" -eq '1' ]]; then
        clean_vms
        exit $?
    fi

    prepare_resources_suite
    if [[ "$GEN" -eq '1' ]]; then
        exit 0
    fi

    auto_select_bridge_name_and_ip
    vagrant_env_prepare

    if [[ "$REMOVE" -eq '1' ]]; then
        echo "RUN: destroy old vm (if exists)"
        vagrant destroy -f
        exit $?
    fi
    if [[ "$INSTALL_VM" -eq '1' ]]; then
        reinstall_vm
        exit $?
    fi
    if [[ "$UP" -eq '1' ]]; then
        vagrant up
        exit $?
    fi
    if [[ "$DOWN" -eq '1' ]]; then
        vagrant halt
        exit $?
    fi
}

main "$@"
