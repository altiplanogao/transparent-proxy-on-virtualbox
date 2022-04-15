# transparent-proxy-on-virtualbox

用VirtualBox创建一个 v2ray 透明代理虚拟机

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## 步骤 0, 安装服务器端

你要买个服务器，并做好配置。这里假设你已经完成了v2ray服务器端的安装。

## 步骤 1, 安装依赖软件

在你的家庭服务器上，安装以下软件:

* git
* virtualbox
* vagrant
* ipcalc

## 步骤 2, 下载这个代码仓，配置并运行

以下命令将在你的家庭服务器内创建一台虚拟机，这台虚拟机将被用做透明代理网关。

``` shell
$ git clone git@github.com:altiplanogao/transparent-proxy-on-virtualbox.git
$ cd transparent-proxy-on-virtualbox
$ # Create config file and update
$ cp config.ini.template config.ini
$ vi config.ini
$ # Run setup.sh script (Note: If an automatic restart is required, then you will be asked to enter the sudo password. That is to say, you needs to be in the sudoer list.)
$ ./setup.sh
```

注意: 安装脚本会自动下载两个v2ray相关工具，如果自动下载失败，请手动下载到'package'目录下。
* v2ray-linux-64.zip: https://github.com/v2fly/v2ray-core/releases
* fhs-install-v2ray: https://github.com/v2fly/fhs-install-v2ray/archive/refs/heads/master.zip

以如下结构放置：
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

## 步骤 3, 配置你的家庭路由器

配置你的路由器，使连接你路由器的那些设备把那台虚拟机作为网关。

通常的方法: 在路由器配置页面的 DHCP 配置项下，使用虚拟机的IP作为默认的网关。(在创建虚拟机时，其IP配置到了这里： config.ini -> $PROXY_IP)
```
$ #### Do the right thing to your router. ####
```

供参考：有时你的路由器未提供设置默认路由的能力，你可以使用你自己的闲置设备。以下是我碰到的情况和我的解决方案:
* 我的 **网件路由器** 支持 DHCP，但不支持对默认路由的配置。
* 我有个 **树莓派** 。
* 我在 **树莓派** 上装了个 **OpenWrt** ，并把它设置为AP (2步):
  1. [OpenWrt as client device](https://openwrt.org/docs/guide-user/network/openwrt_as_clientdevice)
  1. [Enabling a Wi-Fi access point on OpenWrt](https://openwrt.org/docs/guide-quick-start/basic_wifi)
  * 注意：通常情况下，做AP时，DHCP是要被关闭的，但我们将不这样
* 将 **树莓派 OpenWrt** 连上 **网件路由器** LAN，并在 **树莓派 OpenWrt** 配置页定义其使用静态IP(192.168.1.100)，设置IPv4网关为(192.168.1.254) (具体值需参考这里： config.ini -> $PROXY_IP)
* 在这个LAN中，启用两个 2 DHCP 服务，分别使用不同的IP段 (重要：不要有交叠，以避免冲突).
  1. 启动 **Netgear Router** 的DHCP服务，使用IP段: [192.168.1.2, 192.168.1.253]
  2. 启动 **Raspberry OpenWrt** 的DHCP服务，使用IP段: [192.168.2.1, 192.168.2.254]


## 步骤 4, 完成 ...
将你的智能设备（电脑、手机、Pad……）连到你的路由器。

供参考：如果在上面 **树莓派 OpenWrt** 那种情况下，我们则需要连到 **树莓派 OpenWrt** 所开放的热点上。

