#!/usr/bin/env bash

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ];then
    BASEDIR=$(dirname "$0")/../..
    echo "BASEDIR @: \"${BASEDIR}\""
fi

. $BASEDIR/scripts/common.sh

expand_user_config() {
    echo "EXPAND SETTING using \"${ROUTER_ADDRESS}\""
    # will generate (by ipcalc using ${ROUTER_ADDRESS})
    # LAN_NETWORK="10.1.0.0/16"
    # LAN_NETMASK=16
    # LAN_NETMASK_EXPAND="255.255.0.0"
    # ROUTER_IP="10.1.1.1"

    LAN_NETWORK=`ipcalc -n -b ${ROUTER_ADDRESS} | grep Network | sed "s|Network:||g" | sed "s/^[[:space:]]*//g"`
    LAN_NETWORK=`trim ${LAN_NETWORK}`
    echo "LAN_NETWORK: \"${LAN_NETWORK}\""

    local lan_netmask_str=`ipcalc -n -b ${ROUTER_ADDRESS} | grep Netmask | sed "s|Netmask:||g" | sed "s/^[[:space:]]*//g"`
    local lan_netmasks=(${lan_netmask_str//=/ }) 
    LAN_NETMASK_EXPAND=`trim ${lan_netmasks[0]}`
    LAN_NETMASK=`trim ${lan_netmasks[1]}`
    echo "LAN_NETMASK_EXPAND: \"${LAN_NETMASK_EXPAND}\""
    echo "LAN_NETMASK: \"${LAN_NETMASK}\""

    ROUTER_IP=`ipcalc -n -b ${ROUTER_ADDRESS} | grep Address | sed "s|Address:||g" | sed "s/^[[:space:]]*//g"`
    ROUTER_IP=`trim ${ROUTER_IP}`
    echo "ROUTER_IP: \"${ROUTER_IP}\""


    echo "EXPAND SETTING using \"${PROXY_IP}\""
    VM_NAME="v2ray-proxy-${PROXY_IP//./-}-${PROXY_MODE}"
    echo "VM_NAME: \"${VM_NAME}\""
}

expand_config() {
    . $BASEDIR/config.ini
    expand_user_config

    PKG_DIR=$BASEDIR/package
    TPL_DIR=$BASEDIR/templates/vm
    TPL_RESOLVED_DIR=$BASEDIR/vm_templates.resolved

    RELEASE_FILE_NAME="v2ray-linux-$MACHINE.zip"
    RELEASE_FILE="${PKG_DIR}/$RELEASE_FILE_NAME"

    FHS_DIR_NAME="fhs-install-v2ray"
    FHS_DIR="${PKG_DIR}/$FHS_DIR_NAME"
}

download_v2ray() {
    echo "Download $RELEASE_FILE_NAME"

    if [[ -f $RELEASE_FILE ]];then
        echo "  $RELEASE_FILE_NAME exists, skip downloading."
        return 0
    fi

    local DOWNLOAD_LINK="https://github.com/v2fly/v2ray-core/releases/download/$INSTALL_VERSION/v2ray-linux-$MACHINE.zip"

    echo "Downloading V2Ray archive: $DOWNLOAD_LINK"
    if ! curl -x "${PROXY}" -R -H 'Cache-Control: no-cache' -o "$RELEASE_FILE" "$DOWNLOAD_LINK"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    echo "Downloading verification file for V2Ray archive: $DOWNLOAD_LINK.dgst"
    if ! curl -x "${PROXY}" -sSR -H 'Cache-Control: no-cache' -o "$RELEASE_FILE.dgst" "$DOWNLOAD_LINK.dgst"; then
        echo 'error: Download failed! Please check your network or try again.'
        return 1
    fi
    if [[ "$(cat "$RELEASE_FILE".dgst)" == 'Not Found' ]]; then
        echo 'error: This version does not support verification. Please replace with another version.'
        return 1
    fi

    # Verification of V2Ray archive
    for LISTSUM in 'md5' 'sha1' 'sha256' 'sha512'; do
        local SUM="$(${LISTSUM}sum "$ZIP_FILE" | sed 's/ .*//')"
        local CHECKSUM="$(grep ${LISTSUM^^} "$ZIP_FILE".dgst | grep "$SUM" -o -a | uniq)"
        if [[ "$SUM" != "$CHECKSUM" ]]; then
            echo 'error: Check failed! Please check your network or try again.'
            return 1
        fi
    done
}

download_fhs_install_v2ray() {
    echo "Download $FHS_DIR_NAME"
    if [[ -d $FHS_DIR ]]; then
        echo "  $FHS_DIR_NAME exists, skip downloading."
        return 0
    fi
    pushd $PKG_DIR
        git clone https://github.com/v2fly/fhs-install-v2ray.git
    popd
}

fill_templates() {
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

        sed -i "s|%ROUTER_ADDRESS%|${ROUTER_ADDRESS}|g" ${fn}

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

prepare_vagrant_params() {
    echo "Prepare vagrant required parameters"
    local bridge_names=(`VBoxManage list bridgedifs | grep Name | grep -v VBoxNetworkName | sed "s|Name:||g" | sed "s/^[[:space:]]*//g"`)
    local bridge_ips=(`VBoxManage list bridgedifs | grep IPAddress | sed "s|IPAddress:||g" | sed "s/^[[:space:]]*//g"`)
    local bridge_netmasks=(`VBoxManage list bridgedifs | grep NetworkMask | sed "s|NetworkMask:||g" | sed "s/^[[:space:]]*//g"`)
    local bridge_wireless_s=(`VBoxManage list bridgedifs | grep Wireless | sed "s|Wireless:||g" | sed "s/^[[:space:]]*//g"`)
    
    local bridge_count=${#bridge_names[@]}
    local bridge_count_check=${#bridge_ips[@]}
    if (( ${bridge_count}!=${bridge_count_check} )); then
        echo "unexpected bridge output, please check ..."
        exit 1
    fi

    BRIDGE_NAME=""
    BRIDGE_IP=""

    local i=0
    echo "  start checking, expected bridge LAN_NETWORK: \"${LAN_NETWORK}\""
    while [[ $i -lt ${bridge_count} ]]; do
        # PROXY_IP/ROUTER_IP/BRIDGE_IP should in same subnet
        bridge_name=${bridge_names[$i]}
        bridge_ip=${bridge_ips[$i]}
        bridge_netmask=${bridge_netmasks[$i]}
        bridge_wireless=${bridge_wireless_s[$i]}

        network_line=`ipcalc -n -b ${bridge_ip}/${bridge_netmask} | grep Network: | sed "s|Network:||g" | sed "s/^[[:space:]]*//g"`
        local network=`trim ${network_line}`
        echo "  checking bridge #$i: name: ${bridge_name}, ip: ${bridge_ip}/${bridge_netmask}, network: \"${network}\", wireless: ${bridge_wireless}"
        if [ "${network}" = "${LAN_NETWORK}" ] ; then
             BRIDGE_NAME=${bridge_name}
             BRIDGE_IP=${bridge_ip}
        fi
        i=$(($i+1))
    done

    if [ ${BRIDGE_NAME} = "" ] ; then
        echo "No suitable bridge found."
        exit 1
    fi

    echo "  Will use bridge: \"${BRIDGE_NAME}\"(${BRIDGE_IP})"
}

vagrant_env_prepare() {
    PROXY_IP=${PROXY_IP}
    export PROXY_IP
    export BRIDGE_NAME
    export LAN_NETMASK_EXPAND
    export ROUTER_IP
    export VM_NAME
    export PROXY_MODE
}

