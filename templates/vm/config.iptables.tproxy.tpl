#!/usr/bin/env bash

echo "preserve established connection"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# https://guide.v2fly.org/app/tproxy.html
# https://xtls.github.io/document/level-2/transparent_proxy/transparent_proxy.html

# 设置策略路由
echo "define route strategy"
ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

# iptables -t mangle -N V2SKIP
# iptables -t mangle -A V2SKIP -d 127.0.0.1/32 -j RETURN
# iptables -t mangle -A V2SKIP -d 224.0.0.0/4 -j RETURN 
# iptables -t mangle -A V2SKIP -d 240.0.0.0/4 -j RETURN 
# iptables -t mangle -A V2SKIP -d 255.255.255.255/32 -j RETURN 
# iptables -t mangle -A V2SKIP -d %LAN_NETWORK% -p tcp -j RETURN
# iptables -t mangle -A V2SKIP -d %LAN_NETWORK% -p udp ! --dport 53 -j RETURN

# 代理局域网设备
echo "set V2RAY iptables for lan devices"
iptables -t mangle -N V2RAY
iptables -t mangle -A V2RAY -d 127.0.0.1/32 -j RETURN
iptables -t mangle -A V2RAY -d 224.0.0.0/4 -j RETURN 
iptables -t mangle -A V2RAY -d 255.255.255.255/32 -j RETURN
# 添加这两行防止vagrant provision时挂起 （待优化）
iptables -t mangle -A V2RAY -d 10.0.2.0/24 -p tcp -j RETURN
iptables -t mangle -A V2RAY -d 10.0.2.0/24 -p udp ! --dport 53 -j RETURN
#
iptables -t mangle -A V2RAY -d %LAN_NETWORK% -p tcp -j RETURN
iptables -t mangle -A V2RAY -d %LAN_NETWORK% -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY -j RETURN -m mark --mark 0xff
iptables -t mangle -A V2RAY -p udp -j TPROXY --on-ip 127.0.0.1 --on-port %PROXY_TRANSP_PORT% --tproxy-mark 1
iptables -t mangle -A V2RAY -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port %PROXY_TRANSP_PORT% --tproxy-mark 1
echo "APPLY V2RAY"
iptables -t mangle -A PREROUTING -j V2RAY
echo "APPLY V2RAY done"


# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升
echo "set DIVERT iptables"
iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
echo "APPLY DIVERT"
iptables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT
echo "APPLY DIVERT done"


# 代理网关本机
echo "set V2RAY_MASK iptables gateway itself"
iptables -t mangle -N V2RAY_MASK
iptables -t mangle -A V2RAY_MASK -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A V2RAY_MASK -d 255.255.255.255/32 -j RETURN
# 添加这两行防止vagrant provision时挂起（待优化）
iptables -t mangle -A V2RAY_MASK -d 10.0.2.0/24 -p tcp -j RETURN
iptables -t mangle -A V2RAY_MASK -d 10.0.2.0/24 -p udp ! --dport 53 -j RETURN
# 
iptables -t mangle -A V2RAY_MASK -d %LAN_NETWORK% -p tcp -j RETURN
iptables -t mangle -A V2RAY_MASK -d %LAN_NETWORK% -p udp ! --dport 53 -j RETURN
iptables -t mangle -A V2RAY_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A V2RAY_MASK -p udp -j MARK --set-mark 1
iptables -t mangle -A V2RAY_MASK -p tcp -j MARK --set-mark 1
echo "APPLY V2RAY_MASK"
iptables -t mangle -A OUTPUT -j V2RAY_MASK
echo "APPLY V2RAY_MASK done"

