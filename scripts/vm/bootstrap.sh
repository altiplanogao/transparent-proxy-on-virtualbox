#!/usr/bin/env bash

# Enable IP forwarding on the gateway device
enable_ip_forwading() {
    local enabled=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward=1" | grep -v "#" | wc -l`
    echo "ip forwading enabled:" $enabled
    if [ $enabled = "0" ] ; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bk
        echo -e "\nnet.ipv4.ip_forward=1\n" >> /etc/sysctl.conf 
        enabled=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward=1" | grep -v "#" | wc -l`
        echo "ip forwading enabled:" $enabled
    else
        echo "ip forwading already enabled, skip updating \"/etc/sysctl.conf\""
    fi
    
    sysctl -p
}

config_ip_rules() {
    # 设置策略路由
    ip rule add fwmark 1 table 100
    ip route add local 0.0.0.0/0 dev lo table 100

    # 代理局域网设备
    iptables -t mangle -N V2RAY
    iptables -t mangle -A V2RAY -d 127.0.0.1/32 -j RETURN
    iptables -t mangle -A V2RAY -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A V2RAY -d 255.255.255.255/32 -j RETURN
     # 直连局域网，避免 V2Ray 无法启动时无法连网关的 SSH，如果你配置的是其他网段（如 10.x.x.x 等），则修改成自己的
    iptables -t mangle -A V2RAY -d ${LAN_SUB_NET} -p tcp -j RETURN
    # 直连局域网，53 端口除外（因为要使用 V2Ray 的 
    iptables -t mangle -A V2RAY -d ${LAN_SUB_NET} -p udp ! --dport 53 -j RETURN 
     # 给 UDP 打标记 1，转发至 12345 端口
    iptables -t mangle -A V2RAY -p udp -j TPROXY --on-port 12345 --tproxy-mark 1
     # 给 TCP 打标记 1，转发至 12345 端口
    iptables -t mangle -A V2RAY -p tcp -j TPROXY --on-port 12345 --tproxy-mark 1
    iptables -t mangle -A PREROUTING -j V2RAY # 应用规则

    # 代理网关本机
    iptables -t mangle -N V2RAY_MASK
    iptables -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN
     # 直连局域网
    iptables -t mangle -A V2RAY_MASK -d ${LAN_SUB_NET} -p tcp -j RETURN
     # 直连局域网，53 端口除外（因为要使用 V2Ray 的 DNS）
    iptables -t mangle -A V2RAY_MASK -d ${LAN_SUB_NET} -p udp ! --dport 53 -j RETURN
        # 直连 SO_MARK 为 0xff 的流量(0xff 是 16 进制数，数值上等同与上面V2Ray 配置的 255)，此规则目的是避免代理本机(网关)流量出现回环问题
    iptables -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff
       # 给 UDP 打标记,重路由
    iptables -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1
       # 给 TCP 打标记，重路由
    iptables -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1
     # 应用规则
    iptables -t mangle -A OUTPUT -j V2RAY_MASK
}

mv /home/vagrant/vm_templates.resolved /templates.resolved
mv /home/vagrant/package /resources

# set resolved.conf
mv /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bk
cp /templates.resolved/resolved.conf /etc/systemd/resolved.conf

# install v2ray
chmod +x /resources/fhs-install-v2ray/*.sh
echo '' | /resources/fhs-install-v2ray/install-release.sh -l /resources/v2ray-linux-64.zip

# use config file
cp /templates.resolved/config.client /usr/local/etc/v2ray/config.json

# enable service
systemctl enable v2ray
systemctl start v2ray

# set iptables
# https://guide.v2fly.org/en_US/app/transparent_proxy.html
# https://toutyrater.github.io/app/tproxy.html
enable_ip_forwading
cp /templates.resolved/tproxyrule.service /etc/systemd/system/tproxyrule.service

config_transparent_service() {
    config_ip_rules
    mkdir -p /etc/iptables && iptables-save > /etc/iptables/rules.v4
    echo "Print /etc/iptables/rules.v4"
    cat /etc/iptables/rules.v4
    echo ""

    systemctl daemon-reload
    echo "systemctl enable tproxyrule"
    systemctl enable tproxyrule
    service tproxyrule status
    echo "systemctl start tproxyrule"
    systemctl start tproxyrule
    service tproxyrule status
}

# config_transparent_service