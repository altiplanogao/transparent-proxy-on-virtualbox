V2RAY_RELEASE_FILE=""

# use: ${PKG_DIR}, $MACHINE, $INSTALL_VERSION
# will update $RELEASE_FILE_NAME
download_v2ray() {
    local RELEASE_FILE_NAME="v2ray-linux-$MACHINE.zip"
    V2RAY_RELEASE_FILE=${RELEASE_FILE_NAME}
    local RELEASE_FILE="${PKG_DIR}/$RELEASE_FILE_NAME"

    echo "Download $RELEASE_FILE_NAME to \"$RELEASE_FILE\""

    if [[ -f $RELEASE_FILE ]]; then
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

V2RAY_INSTALLER=""
# use: ${PKG_DIR}
# will update: $V2RAY_INSTALLER
download_fhs_install_v2ray() {
    local FHS_DIR_NAME="fhs-install-v2ray"
    V2RAY_INSTALLER=${FHS_DIR_NAME}
    local FHS_DIR="${PKG_DIR}/$FHS_DIR_NAME"
    echo "Download $FHS_DIR_NAME to \"$FHS_DIR\""
    if [[ -d $FHS_DIR ]]; then
        echo "  $FHS_DIR_NAME exists, skip downloading."
        return 0
    fi
    pushd $PKG_DIR
        git clone https://github.com/v2fly/fhs-install-v2ray.git
    popd
}
