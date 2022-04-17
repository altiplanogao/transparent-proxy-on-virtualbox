#!/usr/bin/env bash
# set -o errexit

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ]; then
    BASEDIR=$(dirname "$0")
    echo "BASEDIR @: \"${BASEDIR}\""
fi

WD="${BASEDIR}"
iptables_rules_file="/etc/iptables/rules.v4"

. ${WD}/config.sh
SD=${WD}/scripts
. ${SD}/common.sh
. ${SD}/handle_generic.sh
. ${SD}/handle_v2ray.sh
. ${SD}/handle_templates.sh
. ${SD}/handle_iptables.sh
TPL_DIR=${WD}/templates
TPL_RESOLVED_DIR=${WD}/templates.resolved


check_network() {
    echo "Check network setting. Selected router: ${ROUTER_IP_MASKED}. At least one ip should belong to network: ${LAN_NETWORK}"

    # get all subnets
    local inet_ips=(`ip addr | grep 'state UP' -A2 | grep inet | grep -v inet6 | awk '{print $2}'`)
    for ip in "${inet_ips[@]}"
    do
        local subnet=`ipcalc -nb $ip | grep Network: | sed "s|Network:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
        echo "  checking... ${ip} belongs to ${subnet}"
        if [[ "${LAN_NETWORK}" = "${subnet}" ]]; then
            echo "[SUCCESS]"
            return
        fi
    done

    echo "[FATAL] no ip belongs to network \"${LAN_NETWORK}\", please check"
    exit 1
}

# Enable IP forwarding on the gateway device
enable_ip_forwading() {
    local enabled=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward=1" | grep -v "#" | wc -l`
    echo "enable ip forwading, enabled:" $enabled
    if [ $enabled = "0" ] ; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bk
        echo -e "\nnet.ipv4.ip_forward=1\n" >> /etc/sysctl.conf 
        enabled=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward=1" | grep -v "#" | wc -l`
        echo "ip forwading enabled:" $enabled
    else
        echo "ip forwading already enabled, skip updating \"/etc/sysctl.conf\""
    fi
    
    echo "check ip forwading"
    sysctl -p
}

install_dependency_tools() {
    local codename=`lsb_release -cs`
    cp /etc/apt/sources.list /etc/apt/sources.list.bk

    local from=${WD}/files/${codename}/sources.list
    if [[ -f ${from} ]]; then
        cp ${from} /etc/apt/sources.list
    fi
    apt install net-tools iptables ipcalc -y
}

install_pkgs

install_dependency_tools

expand_net_vars

check_network

resolve_templates

install_and_start_v2ray

enable_ip_forwading

config_ip_rules

config_iptable_autostart
