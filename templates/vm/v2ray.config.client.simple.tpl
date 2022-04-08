{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
    {
      "tag": "socks-inbound",
      "port": PROXY_PORT,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": false,
        "ip": "127.0.0.1"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
  {
    "tag": "proxy",
    "protocol": "vmess",
    "settings": {
      "vnext": [
        {
          "address": "SERVER_IP",
          "port": SERVER_PORT,
          "users": [
            {
              "id": "SERVER_USER_ID",
              "alterId": 0
            }
          ]
        }
      ]
    },
    "mux": {"enabled": true}
  },{
    "tag": "direct",
    "protocol": "freedom",
    "settings": {}
  },{
    "tag": "blocked",
    "protocol": "blackhole",
    "settings": {}
  },{
    "tag": "dns-out",
    "protocol": "dns"
  }],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules":[
      {
        "type": "field",
        "inboundTag": [
          "transparent"
        ],
        "port": 53,
        "network": "udp",
        "outboundTag": "dns-out" 
      },
      {
        "type": "field",
        "domain": ["geosite:cn"],
        "outboundTag": "direct"
      },{
        "type": "field", 
        "ip": [ 
          "223.5.5.5",
          "114.114.114.114"
        ],
        "outboundTag": "direct"
      },
      {
        "type": "field",
        "ip": [ 
          "8.8.8.8",
          "1.1.1.1"
        ],
        "outboundTag": "proxy"
      },
      {
        "type": "field",
        "ip": [
          "geoip:cn",
          "geoip:private"
        ],
        "outboundTag": "direct"
      },
      {
        "type": "field",
        "network": "udp,tcp",
        "outboundTag": "proxy"
      }
    ]
  },

  "dns": {
    "hosts": {
      "domain:v2fly.org": "www.vicemc.net",
      "domain:github.io": "pages.github.com",
      "domain:wikipedia.org": "www.wikimedia.org",
      "domain:shadowsocks.org": "electronicsrealm.com"
    },
    "servers": [
      "8.8.8.8",
      "1.1.1.1",
      {
        "address": "114.114.114.114",
        "port": 53,
        "domains": [
          "geosite:cn"
        ]
      },
      "localhost"
    ]
  },

  "policy": {
    "levels": {
      "0": {
        "uplinkOnly": 0,
        "downlinkOnly": 0
      }
    },
    "system": {
      "statsInboundUplink": false,
      "statsInboundDownlink": false,
      "statsOutboundUplink": false,
      "statsOutboundDownlink": false
    }
  },
  "other": {}
}