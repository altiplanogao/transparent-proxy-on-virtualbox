#!/usr/bin/env bash

. /templates.resolved/configuration.ini
# options: simple,redirect,tproxy.(only simple tested)
proxy_mode=${PROXY_MODE}

iptables_rules_file="/etc/iptables/rules.v4"

prepare_resources() {
    echo "[apply]: prepare resources"
    mv /home/vagrant/vm_templates.resolved /templates.resolved
    mv /home/vagrant/package /resources
}

update_resolved_conf() {
    # set resolved.conf
    echo "[apply]: resolved.conf"
    mv /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bk
    cp /templates.resolved/resolved.conf /etc/systemd/resolved.conf

    echo "service networking restart"
    service networking restart
}

install_and_start_v2ray() {
    # install v2ray
    echo "install v2ray using: fhs-install-v2ray"
    chmod +x /resources/fhs-install-v2ray/*.sh
    echo '' | /resources/fhs-install-v2ray/install-release.sh -l /resources/v2ray-linux-64.zip

    # use config file
    echo "apply prepared v2ray config"
    cp /templates.resolved/v2ray.config.client.${proxy_mode} /usr/local/etc/v2ray/config.json

    # enable service
    echo "enable v2ray service"
    systemctl enable v2ray
    systemctl start v2ray
}

config_network() {
    netplan set ethernets.eth1.dhcp4=false
    netplan set ethernets.eth1.gateway4=${ROUTER_IP}
    netplan apply
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

config_ip_rules() {
    echo "config ip rules start"
    . /templates.resolved/config.iptables.${proxy_mode}
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
    cp /templates.resolved/tproxyrule.service /etc/systemd/system/tproxyrule.service

    systemctl daemon-reload
    echo "systemctl enable tproxyrule"
    systemctl enable tproxyrule
    service tproxyrule status
    echo "systemctl start tproxyrule"
    systemctl start tproxyrule
    service tproxyrule status
}

prepare_resources

# update_resolved_conf

install_and_start_v2ray

config_network

enable_ip_forwading

# config_ip_rules

# config_transparent_service() {

#     config_iptable_autostart
# }

# config_transparent_service

# # update root password
# echo -e "password\npassword" | passwd