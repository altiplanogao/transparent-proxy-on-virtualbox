#!/usr/bin/env bash

# ip route show to default | grep -v dhcp | grep "via 10.2.1.1"
# if no entry found:
#    sudo ip route add default via 10.2.1.1

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ]; then
    BASEDIR=$(dirname "$0")
    echo "BASEDIR @: \"${BASEDIR}\""
fi

WD="${BASEDIR}/.."
SD=${BASEDIR}

. ${WD}/config.sh
. ${SD}/common.sh
. ${SD}/handle_network.sh

expand_net_vars

ensure_default_route_exist


