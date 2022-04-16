
config_ip_rules() {
    echo "config ip rules start"
    ${WD}/scripts/config.iptables.${PROXY_MODE}.sh
    echo "config ip rules done, will store rules to: ${iptables_rules_file}"
    mkdir -p /etc/iptables && iptables-save > ${iptables_rules_file}
    echo "Print ${iptables_rules_file}"
    cat ${iptables_rules_file}
    echo "Config ip rules finished"
}

config_iptable_autostart() {
    # set iptables
    # https://guide.v2fly.org/en_US/app/transparent_proxy.html
    # https://toutyrater.github.io/app/tproxy.html
    echo "deploy auto iptables rules service: "
    cp ${WD}/files/tproxyrule.service /etc/systemd/system/tproxyrule.service

    systemctl daemon-reload
    echo "systemctl enable tproxyrule"
    systemctl enable tproxyrule
    # service tproxyrule status
    # echo "systemctl start tproxyrule"
    # systemctl start tproxyrule
    # service tproxyrule status
}
