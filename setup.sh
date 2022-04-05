#!/usr/bin/env bash

expand_config() {
  BASEDIR=$(dirname "$0")
  . $BASEDIR/config.sh
  . $BASEDIR/settings.ini

  PKG_DIR=$BASEDIR/package

  RELEASE_FILE_NAME="v2ray-linux-$MACHINE.zip"
  RELEASE_FILE="${PKG_DIR}/$RELEASE_FILE_NAME"

  FHS_DIR_NAME="fhs-install-v2ray"
  FHS_DIR="${PKG_DIR}/$FHS_DIR_NAME"
}

download_v2ray() {
    if [[ -f $RELEASE_FILE ]];then
        echo "$RELEASE_FILE_NAME exists, skip downloading."
        return 0
    fi

  DOWNLOAD_LINK="https://github.com/v2fly/v2ray-core/releases/download/$INSTALL_VERSION/v2ray-linux-$MACHINE.zip"

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
    SUM="$(${LISTSUM}sum "$ZIP_FILE" | sed 's/ .*//')"
    CHECKSUM="$(grep ${LISTSUM^^} "$ZIP_FILE".dgst | grep "$SUM" -o -a | uniq)"
    if [[ "$SUM" != "$CHECKSUM" ]]; then
      echo 'error: Check failed! Please check your network or try again.'
      return 1
    fi
  done
}

download_fhs_install_v2ray() {
    if [[ -d $FHS_DIR ]]; then
        echo "$FHS_DIR_NAME exists, skip downloading."
        return 0
    fi
    pushd $PKG_DIR
        git clone https://github.com/v2fly/fhs-install-v2ray.git
    popd
}

fill_templates() {
    return 0
}

vagrant_up() {
    return 0
}

main() {
    expand_config
    download_v2ray
    download_fhs_install_v2ray
    fill_templates
    vagrant_up
}

main "$@"