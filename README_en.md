# transparent-proxy-on-virtualbox
Create a transparent proxy vm using virtualbox.

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## Step 1, Install software dependencies

On your home server, install following:

* virtualbox
* vagrant
* ipcalc

## Step 2, Download this repo, config and run

The following command will setup a vm inside the host, and the vm could be used as a gateway device which supports transparent proxy.

``` shell
$ git clone git@github.com:altiplanogao/transparent-proxy-on-virtualbox.git
$ cd transparent-proxy-on-virtualbox
$ # Create config file
$ cp config.ini.template config.ini
$ vi config.ini
$ # Run setup.sh script (Note: If an automatic restart is required, then you will be asked to enter the sudo password. That is to say, you needs to be in the sudoer list.)
$ ./setup.sh
```

Note: The script will download v2ray automatically. If auto downloading fails, please download binary files and save to 'package' directory manually.
* v2ray-linux-64.zip: https://github.com/v2fly/v2ray-core/releases
* fhs-install-v2ray: https://github.com/v2fly/fhs-install-v2ray/archive/refs/heads/master.zip
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

## Step 3, Config your home router

Make the router's clients to use the vm as their default gateway.

Typical method: on your router's config page, update the gateway address under dhcp setting. Update it using the vm's ip. (see config.ini -> $PROXY_IP)
```
$ #### Do the right thing to your router. ####
```

## Step 4, Aha ...
Connect any device to the router without any proxy setting. Enjoy ... 

