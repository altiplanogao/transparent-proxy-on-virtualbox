# transparent-proxy-gateway

把Linux主机配置为 v2ray 透明代理网关。有两种配置方式：配置到主机、配置到虚拟机。

* 配置到主机时，将直接把v2ray及配置安装到主机内。
    * 以下OS经测试: Ubuntu/focal64、 Debian/bullseye64、 Raspberry Pi OS
* 配置到虚拟机时，将在主机内安装一个虚拟机，然后把v2ray及配置安装到虚拟机内。
    * 虚拟机网络将和主机网络桥接（即在同一个子网内）
    * 需安装虚拟机软件: [VirtualBox](https://www.virtualbox.org/)、[Vagrant](https://www.vagrantup.com/downloads)
    * 以下主机OS经测试: Ubuntu/focal64、macOS Monterey

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## 步骤 0, 前置条件

1. 一个外网服务器，并已做好v2ray服务端配置

## 步骤 1, 安装依赖软件

主机安装以下软件: git、ipcalc
``` shell
$ # 如为Debian
$ sudo apt install git ipcalc

$ # 如为macOS (Homebrew)
$ brew install ipcalc
$ brew install git
```

## 步骤 2, 下载代码，配置并运行

在主机上执行以下命令。

``` shell
$ # 下载代码
$ git clone git@github.com:altiplanogao/transparent-proxy-on-virtualbox.git
$ cd transparent-proxy-on-virtualbox
$ # 从模板创建配置文件
$ cp config.ini.template config.ini
$ # 配置
$ vi config.ini
```
安装到主机
``` shell
$ # 安装到主机（命令用户需在sudoer清单中）
$ sudo ./setup.sh -il
```
安装到虚拟机
``` shell
$ # 安装到虚拟机（如需开机自动启动，则用户需在sudoer中）
$ ./setup.sh
```

注意: 安装脚本会自动下载两个v2ray相关工具，如果自动下载失败，请手动下载到'package'目录下。
* [v2ray-linux-64.zip](https://github.com/v2fly/v2ray-core/releases)
* [fhs-install-v2ray](https://github.com/v2fly/fhs-install-v2ray/archive/refs/heads/master.zip)

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

## 步骤 3, 配置路由器

配置路由器，使连接路由器的设备把上述主机(或虚拟机)作为网关。

通常的方法: 在路由器配置页 DHCP 配置项下，使用主机(或虚拟机)的IP作为默认的网关。(在创建虚拟机时，其IP配置到了这里： config.ini -> $PROXY_IP)
```
$ #### Do the right thing to your router. ####
```

## 步骤 4, 完成 ...
将智能设备（电脑、手机、Pad……）连到你的路由器。

## 其它
* 手动安装:
可以先生成安装脚本
```bash
$ # 生成安装脚本目录（生成的文件位于 ./vm.resources.suite）
$ ./setup.sh -g
```
把目录（./vm.resources.suite）拷贝到目标主机上，再执行如下命令：
```bash
$ sudo ./bootstrap.sh
```
* 以docker service运行客户端，参考[这里](vm.resources/README.md)


## 参考
1. [v2ray-core](https://github.com/v2fly/v2ray-core)
1. [fhs-install-v2ray](https://github.com/v2fly/fhs-install-v2ray)
1. https://guide.v2fly.org/app/tproxy.html
