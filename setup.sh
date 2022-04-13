#!/usr/bin/env bash
set -o errexit

BASEDIR=$(dirname "$0")

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

restart() {
    do_install_vm
    ask_and_do_setup_autostart
}

# ===============================================
## Demo function for processing parameters
judgment_parameters() {
    if [[ "$#" -eq '0' ]]; then
        INSTALL='1'
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
      '--install')
        if [[ "$#" -gt '1' ]]; then
          echo 'error: Please enter the correct parameters.'
          exit 1
        fi
        INSTALL='1'
        ;;
      '-c' | '--clean')
        CLEAN='1'
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
  echo "usage: $0 [--remove | --install | -c | -u | -d | -h]"
  echo '  --remove        Remove installed vm'
  echo '  --install       Installed proxy vm (the default action)'
  echo '  -c, --clean     Remove all installed vm'
  echo '  -u, --up        Start the vm'
  echo '  -d, --down      Stop the vm'
  echo '  -h, --help      Show help'
  
  exit 0
}

clean_vms() {
# vboxmanage list vms
# vboxmanage unregistervm v2ray-proxy-**** --delete
    echo "TODO: clean_vms"
}

main() {
    judgment_parameters "$@"
    [[ "$HELP" -eq '1' ]] && show_help

    . $BASEDIR/scripts/host/utils.sh
    . $BASEDIR/scripts/common.sh

    should_run_as_normal_user
    expand_config
    prepare_vagrant_params
    vagrant_env_prepare

    if [[ "$REMOVE" -eq '1' ]]; then
        echo "RUN: destroy old vm (if exists)"
        vagrant destroy -f
        exit $?
    fi
    if [[ "$INSTALL" -eq '1' ]]; then
        restart
        exit $?
    fi
    if [[ "$CLEAN" -eq '1' ]]; then
        clean_vms
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
