
install_and_start_v2ray() {
    # install v2ray
    echo "install v2ray using: fhs-install-v2ray"
    local bin=${WD}/package/${V2RAY_RELEASE_FILE}
    local installer=${WD}/package/${V2RAY_INSTALLER}
    chmod +x ${installer}/*.sh
    
    echo "Command: ${installer}/install-release.sh -l ${bin}"
    echo '' | ${installer}/install-release.sh -l ${bin}

    # use config file
    echo "apply prepared v2ray config"
    cp "${WD}/templates.resolved/v2ray.config.client.${PROXY_MODE}" /usr/local/etc/v2ray/config.json

    # enable service
    echo "enable v2ray service"
    systemctl enable v2ray
    systemctl start v2ray
}
