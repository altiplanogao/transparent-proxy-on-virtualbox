
# use #LAN_NETWORK
auto_select_bridge_name_and_ip() {
    echo "Try to select bridge name/ip with LAN_NETWORK: \"${LAN_NETWORK}\""

    local PRE_IFS=${IFS}
    IFS=$'\n'
    local bridge_names=(`VBoxManage list bridgedifs | grep "Name:" | grep -v VBoxNetworkName | sed "s|Name:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`)
    IFS=${PRE_IFS}

    local bridge_ips=(`VBoxManage list bridgedifs | grep "IPAddress:" | sed "s|IPAddress:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`)
    local bridge_netmasks=(`VBoxManage list bridgedifs | grep "NetworkMask:" | sed "s|NetworkMask:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`)
    local bridge_wireless_s=(`VBoxManage list bridgedifs | grep "Wireless:" | sed "s|Wireless:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`)
   
    local bridge_count=${#bridge_names[@]}
    local bridge_count_check=${#bridge_ips[@]}

    if (( "${bridge_count}" != "${bridge_count_check}" )); then
        echo "unexpected bridge output, please check ... ("${bridge_count}" != "${bridge_count_check}")"
        exit 1
    fi

    BRIDGE_NAME=""
    BRIDGE_IP=""

    local i=0
    echo "  start checking, expected bridge LAN_NETWORK: \"${LAN_NETWORK}\""
    while [[ $i -lt ${bridge_count} ]]; do
        # PROXY_IP/ROUTER_IP/BRIDGE_IP should in same subnet
        bridge_name=${bridge_names[$i]}
        bridge_ip=${bridge_ips[$i]}
        bridge_netmask=${bridge_netmasks[$i]}
        bridge_wireless=${bridge_wireless_s[$i]}

        network_line=`ipcalc -n -b ${bridge_ip}/${bridge_netmask} | grep Network: | sed "s|Network:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
        local network=${network_line}
        echo "  checking bridge candidate #$i: [${bridge_name}], ip: ${bridge_ip}/${bridge_netmask}, network: \"${network}\", wireless: ${bridge_wireless}"
        if [ "${network}" = "${LAN_NETWORK}" ] ; then
             BRIDGE_NAME=${bridge_name}
             BRIDGE_IP=${bridge_ip}
        fi
        i=$(($i+1))
    done
 
    if [ "${BRIDGE_NAME}" = "" ] ; then
        echo "No suitable bridge found."
        exit 1
    fi

    echo "  Selected to be bridge: \"${BRIDGE_NAME}\"(${BRIDGE_IP})"
}
