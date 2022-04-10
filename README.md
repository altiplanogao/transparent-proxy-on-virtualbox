# transparent-proxy-on-virtualbox

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## install software dependencies

* virtualbox
* vagrant
* ipcalc

## create setting file

``` shell
git clone git@github.com:altiplanogao/transparent-proxy-on-virtualbox.git
cd transparent-proxy-on-virtualbox
cp config.ini.template config.ini
vi config.ini
```

## update arch or v2ray version if necessary
```
$ vi config_v2ray.sh
```

## run using normal user (with sudo privilege)
``` shell
$ ./setup.sh
```

## Tips: download binary files and save to 'package' directory if auto downloading fails
```
$ pwd
.../transparent-proxy-on-virtualbox
$ tree
.
├── package
│   ├── fhs-install-v2ray
│   │   ├── install-dat-release.sh
│   │   ├── install-release.sh
│   │   ├── LICENSE
│   │   ├── README.md
│   │   └── README.zh-Hans-CN.md
│   └── v2ray-linux-64.zip
├── <... whatever ...>
├── <... whatever ...>
└── <... whatever ...>
```

Config default gateway on your home router

Tips: to install an AP device on raspberry (2 steps only):
* [OpenWrt as client device](https://openwrt.org/docs/guide-user/network/openwrt_as_clientdevice)
* [Enabling a Wi-Fi access point on OpenWrt](https://openwrt.org/docs/guide-quick-start/basic_wifi)
