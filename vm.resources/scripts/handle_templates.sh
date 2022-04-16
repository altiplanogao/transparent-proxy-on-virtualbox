resolve_templates() {
    echo "Apply templates"
    rm -rf ${TPL_RESOLVED_DIR}
    cp -r ${TPL_DIR} ${TPL_RESOLVED_DIR}
    for fn in ${TPL_RESOLVED_DIR}/*.tpl
    do
        local newfn=${fn:0:-4}
        echo "  processing: ${fn} -> ${newfn}"

        sed -i "s|%SERVER_IP%|${SERVER_IP}|g" ${fn}
        sed -i "s|%SERVER_PORT%|${SERVER_PORT}|g" ${fn}
        sed -i "s|%SERVER_USER_ID%|${SERVER_USER_ID}|g" ${fn}

        sed -i "s|%ROUTER_IP_MASKED%|${ROUTER_IP_MASKED}|g" ${fn}

        sed -i "s|%PROXY_IP%|${PROXY_IP}|g" ${fn}
        sed -i "s|%PROXY_PORT%|${PROXY_PORT}|g" ${fn}
        sed -i "s|%PROXY_TRANSP_PORT%|${PROXY_TRANSP_PORT}|g" ${fn}

        sed -i "s|%ROUTER_IP%|${ROUTER_IP}|g" ${fn}
        sed -i "s|%LAN_NETWORK%|${LAN_NETWORK}|g" ${fn}
        sed -i "s|%LAN_NETMASK%|${LAN_NETMASK}|g" ${fn}
        sed -i "s|%LAN_NETMASK_EXPAND%|${LAN_NETMASK_EXPAND}|g" ${fn}

        sed -i "s|%VM_NAME%|${VM_NAME}|g" ${fn}
        sed -i "s|%PROXY_MODE%|${PROXY_MODE}|g" ${fn}

        mv $fn $newfn
    done
}
