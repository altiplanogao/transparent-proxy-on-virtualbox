
install_dependency_tools() {
    local codename=`lsb_release -cs`
    echo "CODENAME: ${codename}"
    cp /etc/apt/sources.list /etc/apt/sources.list.bk
 
    local from=${WD}/files/${codename}/sources.list
    if [[ -f ${from} ]]; then
        cp ${from} /etc/apt/sources.list.d/sources.list
    fi
    echo "[apt-get update]"
    apt-get update
    
    echo "[Install Dependency]"
    apt-get install net-tools iptables ipcalc -y
    echo "[Install Dependency] done"
}

install_deb_pkgs() {
    echo "[Install] DEB packages"
    pushd ${WD}/package
        dpkg --install *.deb
    popd
}
