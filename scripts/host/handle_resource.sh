
echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ];then
    BASEDIR=$(dirname "$0")/../..
    echo "BASEDIR @: \"${BASEDIR}\""
fi

prepare_resources_suite() {
    vm_res_dir="${BASEDIR}/vm.resources"
    vm_res_suite_dir="${BASEDIR}/vm.resources.suite"

    echo "Prepare vm resources"
    rm -rf ${vm_res_suite_dir}
    cp -r ${vm_res_dir} ${vm_res_suite_dir}

    echo "  copy packages"
    pushd "${BASEDIR}/package"
        apt-get download ipcalc || true
    popd
    cp -rf "${BASEDIR}/package" "${vm_res_suite_dir}/package"

    echo "  prepare common scripts"
    cp ${BASEDIR}/scripts/common.sh "${vm_res_suite_dir}/scripts"

    echo "  copy ssh setting"
    cp ~/.ssh/id_rsa.pub "${vm_res_suite_dir}/.ssh/"
    cp ~/.ssh/authorized_keys "${vm_res_suite_dir}/.ssh/"

    echo "  prepare config file"
    local target_config_script="${vm_res_suite_dir}/config.sh"
    cp ${BASEDIR}/config.ini "${target_config_script}"
    # "fhs-install-v2ray"

    cat >> ${target_config_script} <<EOL

# v2ray installer
V2RAY_INSTALLER="${V2RAY_INSTALLER}"
# v2ray release file
V2RAY_RELEASE_FILE="${V2RAY_RELEASE_FILE}"

EOL
}