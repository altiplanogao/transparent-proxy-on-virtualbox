#!/usr/bin/env bash

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ];then
    BASEDIR=$(dirname "$0")/../..
echo "BASEDIR @: \"${BASEDIR}\""
fi

. ${BASEDIR}/scripts/common.sh
. ${BASEDIR}/scripts/host/utils.sh

main() {
    expand_config
    check_if_running_as_root
    
    chmod +x $BASEDIR/scripts/host/*.sh
    print_env
    $BASEDIR/scripts/host/setup_gateway_proxy.sh
}

main "$@"