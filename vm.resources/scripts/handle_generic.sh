
install_pkgs() {
    echo "Install DEB packages"
    pushd ${WD}/package
        dpkg --install *.deb
    popd
}
