#!/usr/bin/env bash

# ip route show to default | grep -v dhcp | grep "via 10.2.1.1"
# if no entry found:
#    sudo ip route add default via 10.2.1.1

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ]; then
    BASEDIR=$(dirname "$0")
    echo "BASEDIR @: \"${BASEDIR}\""
fi

WD="${BASEDIR}"

. ${WD}/config.sh
SD=${WD}/scripts
. ${SD}/common.sh
. ${SD}/handle_network.sh

expand_net_vars

ensure_default_route_exist

/sbin/ip rule add fwmark 1 table 100
/sbin/ip route add local 0.0.0.0/0 dev lo table 100

/sbin/iptables-restore /etc/iptables/rules.v4
