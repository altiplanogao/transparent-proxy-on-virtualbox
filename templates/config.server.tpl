{
    "log": {
        "loglevel": "warning",
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log"
    },
    "inbounds": [
        {
            "port": SERVER_PORT,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "SERVER_USER_ID",
                        "alterId": 0
                    }
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}