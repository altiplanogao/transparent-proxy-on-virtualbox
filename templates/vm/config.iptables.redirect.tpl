#!/usr/bin/env bash

echo "preserve established connection"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "config rules for subnet"
# 新建一个名为 V2RAY 的链
iptables -t nat -N V2RAY 
# 直连 %LAN_NETWORK% 
iptables -t nat -A V2RAY -d %LAN_NETWORK% -j RETURN 
# 直连 SO_MARK 为 0xff 的流量(0xff 是 16 进制数，数值上等同与上面配置的 255)，此规则目的是避免代理本机(网关)流量出现回环问题
iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff 
# 其余流量转发到 %PROXY_TRANSP_PORT% 端口（即 V2Ray）
iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports %PROXY_TRANSP_PORT%
# 对局域网其他设备进行透明代理
iptables -t nat -A PREROUTING -p tcp -j V2RAY 
# 对本机进行透明代理
iptables -t nat -A OUTPUT -p tcp -j V2RAY 

echo "config rules for localhost"
ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -N V2RAY_MASK
iptables -t mangle -A V2RAY_MASK -d %LAN_NETWORK% -j RETURN
iptables -t mangle -A V2RAY_MASK -p udp -j TPROXY --on-port %PROXY_TRANSP_PORT% --tproxy-mark 1
iptables -t mangle -A PREROUTING -p udp -j V2RAY_MASK
