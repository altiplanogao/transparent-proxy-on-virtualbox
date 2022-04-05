#!/usr/bin/env bash

. ./scripts/common.sh

expand_config() {
    BASEDIR=$(dirname "$0")
}

main() {
    expand_config
    check_if_running_as_root
    
    chmod +x $BASEDIR/scripts/host/*.sh
    
    $BASEDIR/scripts/host/setup_vm_auto_start.sh
}

main "$@"