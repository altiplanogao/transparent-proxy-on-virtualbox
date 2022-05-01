
install_and_start_v2ray() {
    # install v2ray
    echo "[INSTALL] v2ray using: fhs-install-v2ray"
    local bin=${WD}/package/${V2RAY_RELEASE_FILE}
    local installer=${WD}/package/${V2RAY_INSTALLER}
    chmod +x ${installer}/*.sh
    
    echo "using command: ${installer}/install-release.sh -l ${bin}"
    echo '' | ${installer}/install-release.sh -l ${bin}

    # use config file
    echo "[Apply config] prepared v2ray config"
    cp "${WD}/templates.resolved/v2ray.config.client.${PROXY_MODE}" /usr/local/etc/v2ray/config.json

    # enable service
    echo "[Enable] v2ray service"
    systemctl enable v2ray
    systemctl start v2ray

    echo "[Update v2ray data], after proxy enabled"
    /usr/local/bin/install-dat-release > /dev/null 2>&1

    # daily update data
    echo "[Setup crontab]: daily-update v2ray data"
    install -m 755 ${installer}/install-dat-release.sh /usr/local/bin/install-dat-release
    echo "Crontab: remove previous setting"
    crontab -l | grep -v '/usr/local/bin/install-dat-release' | crontab -
    echo "Crontab: add daily task (data update)"
    (crontab -l ; echo "0 0 * * * /usr/local/bin/install-dat-release > /dev/null 2>&1") | crontab -
    echo "Crontab: check"
    # check log by: grep CRON /var/log/syslog
    crontab -l
}
