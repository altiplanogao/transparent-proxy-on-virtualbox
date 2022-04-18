
install_dependency_tools() {
    local codename=`lsb_release -cs`
    cp /etc/apt/sources.list /etc/apt/sources.list.bk

    local from=${WD}/files/${codename}/sources.list
    if [[ -f ${from} ]]; then
        cp ${from} /etc/apt/sources.list
    fi
    apt install net-tools iptables ipcalc -y
}

install_deb_pkgs() {
    echo "Install DEB packages"
    pushd ${WD}/package
        dpkg --install *.deb
    popd
}
