#!/usr/bin/env bash

expand_config() {
    BASEDIR=$(dirname "$0")
    . $BASEDIR/config.sh
    . $BASEDIR/settings.ini

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
        sed -i "s|SERVER_IP|${SERVER_IP}|g" ${fn}
        sed -i "s|SERVER_PORT|${SERVER_PORT}|g" ${fn}
        sed -i "s|SERVER_USER_ID|${SERVER_USER_ID}|g" ${fn}
        sed -i "s|ROUTER_IP|${ROUTER_IP}|g" ${fn}
        sed -i "s|PROXY_IP|${PROXY_IP}|g" ${fn}
        sed -i "s|PROXY_PORT|${PROXY_PORT}|g" ${fn}
        sed -i "s|SERVER_TRANSP_PORT|${SERVER_TRANSP_PORT}|g" ${fn}
        sed -i "s|LAN_SUB_NET|${LAN_SUB_NET}|g" ${fn}

        mv $fn $newfn
    done
}

rough_subnet_mask_compare() {
    local a=$1
    local b=$2
    
    local i=1
    while [ $i -le 4 ]
    do
        local ai=`echo $a | cut -d'.' -f${i}`
        local bi=`echo $b | cut -d'.' -f${i}`
        if (( ${ai}!=${bi} )); then
            return $(( $i - 1 ))
        fi

        i=$(($i+1))
    done
}

prepare_vagrant_params() {
    echo "Prepare vagrant required parameters"
    local bridge_names=(`VBoxManage list bridgedifs | grep Name | grep -v VBoxNetworkName | sed "s|Name:||g" | sed "s/^[[:space:]]*//g"`)
    local bridge_ips=(`VBoxManage list bridgedifs | grep IPAddress | sed "s|IPAddress:||g" | sed "s/^[[:space:]]*//g"`)
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
    local best_hits=0
    while [ $i -lt ${bridge_count} ]
    do
        # PROXY_IP/ROUTER_IP/BRIDGE_IP should in same subnet
        bridge_name=${bridge_names[$i]}
        bridge_ip=${bridge_ips[$i]}
        bridge_wireless=${bridge_wireless_s[$i]}

        rough_subnet_mask_compare ${ROUTER_IP} ${bridge_ip}
        hits=$?
        if (( ${hits} <= 4 && ${hits} > ${best_hits} )); then
            best_hits=${hits}
            BRIDGE_NAME=${bridge_name}
            BRIDGE_IP=${bridge_ip}
        fi

        echo "  checking bridge #$i: name: ${bridge_name}, ip: ${bridge_ip}, wireless:${bridge_wireless}, hits: ${hits}"
        i=$(($i+1))
    done

    if [ ${BRIDGE_NAME} = "" ] ; then
        echo "No suitable bridge found."
        exit 1
    fi

    echo "  Will use bridge: \"${BRIDGE_NAME}\"(${BRIDGE_IP})"
}

vagrant_up() {
    LAN_IP=${PROXY_IP}
    export LAN_IP
    export BRIDGE_NAME
    echo "Pull up proxy vm using \"${BRIDGE_NAME}\"(${LAN_IP})"

    pushd $BASEDIR
        # vagrant destroy -f
        vagrant up
    popd
}

main() {
    expand_config
    download_v2ray
    download_fhs_install_v2ray
    fill_templates
    prepare_vagrant_params
    vagrant_up
}

main "$@"