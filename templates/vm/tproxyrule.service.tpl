[Unit]
Description=Tproxy rule
After=network.target
Wants=network.target

[Service]

Type=oneshot
ExecStart=/sbin/ip rule add fwmark 1 table 100 ; /sbin/ip route add local 0.0.0.0/0 dev lo table 100 ; /sbin/iptables-restore /etc/iptables/rules.v4

[Install]
WantedBy=multi-user.target
