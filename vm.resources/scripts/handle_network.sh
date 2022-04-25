
check_network() {
    echo "Check network setting. Selected router: ${ROUTER_IP_MASKED}. The host should have at least one ip belonging to the network: ${LAN_NETWORK}"

    # get all subnets
    local inet_ips=(`ip addr | grep 'state UP' -A2 | grep inet | grep -v inet6 | awk '{print $2}'`)
    for ip in "${inet_ips[@]}"
    do
        local subnet=`ipcalc -nb $ip | grep Network: | sed "s|Network:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
        local address=`ipcalc -nb $ip | grep Address: | sed "s|Address:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
        echo "  checking... ${ip} belongs to ${subnet}"
        if [[ "${LAN_NETWORK}-${PROXY_IP}" = "${subnet}-${address}" ]]; then
            echo "[SUCCESS] found: ${ip} belongs to ${subnet}."
            return
        fi
    done

    echo "[FATAL] please check : 1. if ${PROXY_IP} belongs to the host? 2. if the ip belongs to network \"${LAN_NETWORK}\""
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

ensure_default_route_exist() {
    local default_route=`ip route show to default | grep -v dhcp | grep "via ${ROUTER_IP}" | wc -l`
    echo "Ensure default route exist:" ${ROUTER_IP}
    if [ "$default_route" = "0" ] ; then
        echo " add default route " ${ROUTER_IP}
        ip route add default via "${ROUTER_IP}" || true
    fi
}
