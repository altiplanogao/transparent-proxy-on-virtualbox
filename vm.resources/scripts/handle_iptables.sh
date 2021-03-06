iptables_rules_file="/etc/iptables/rules.v4"

config_ip_rules() {
    print_block_header "CONFIG IP RULE START"
    export PROXY_TRANSP_PORT
    ${WD}/scripts/config.iptables.${PROXY_MODE}.sh
    echo "config ip rules done, will store rules to: ${iptables_rules_file}"
    mkdir -p /etc/iptables && iptables-save > ${iptables_rules_file}
    print_block_footer "CONFIG IP RULE DONE"
}

config_iptable_autostart() {
    # set iptables
    # https://guide.v2fly.org/en_US/app/transparent_proxy.html
    # https://toutyrater.github.io/app/tproxy.html
    echo "deploy auto iptables rules service: "
    cp ${WD}/files/tproxyrule.service /etc/systemd/system/tproxyrule.service
    cp ${WD}/files/ip_change_mon.service /etc/systemd/system/ip_change_mon.service

    systemctl daemon-reload
    echo "systemctl enable tproxyrule, ip_change_mon"
    systemctl enable tproxyrule
    systemctl enable ip_change_mon
    # service tproxyrule status
    # echo "systemctl start tproxyrule"
    # systemctl start tproxyrule
    # service tproxyrule status
}
