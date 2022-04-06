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

pushd $BASEDIR
    echo "RUN: destroy old vm (if exists)"
    # sudo -u ${username} 'vagrant destroy -f'
    vagrant destroy -f

    echo "RUN: setup vm"
    # /bin/su -c  './setup_vm.sh' ${username}
    ./setup_vm.sh

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
