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

FYI: Sometimes, your router doesn't provide a method to set default gateway for clients.
Here is my condition & solution:
* My **Netgear Router** supports DHCP, but doesn't provide default gateway setting.
* I have a Raspberry board.
* So, I install **OpenWrt** on the **Raspberry**, and set it up as an AP device (2 steps):
  1. [OpenWrt as client device](https://openwrt.org/docs/guide-user/network/openwrt_as_clientdevice)
  1. [Enabling a Wi-Fi access point on OpenWrt](https://openwrt.org/docs/guide-quick-start/basic_wifi)
  * Note: Normally, when the router is an AP, DHCP is turned off, but we will not do this. 
* Connect **Raspberry OpenWrt** to **Netgear Router**'s LAN port, and config static IP(192.168.1.100), set IPv4 gateway(192.168.1.254) (please refer to $PROXY_IP in config.ini for real value)
* Start 2 DHCP servers on the same LAN with different IP range (IMPORTANT: DO NOT OVERLAP, TO AVOID CONFLICT).
  1. Start DHCP server on **Netgear Router** with range [192.168.1.2, 192.168.1.253]
  2. Start DHCP server on **Raspberry OpenWrt** with range [192.168.2.1, 192.168.2.254]

## Step 4, Aha ...
Connect any device to the router without any proxy setting. Enjoy ... 

