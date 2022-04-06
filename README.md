# transparent-proxy-on-virtualbox

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## install software dependencies

* virtualbox
* vagrant

## create setting file

``` shell
cp settings.ini.template settings.ini
vi settings.ini
```

## run using normal user (with sudo privilege)
``` shell
$ ./setup.sh
```

## update arch or v2ray version if necessary
```
$ vi config.sh
```

## download binary files and save to 'package' directory if auto downloading fails
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