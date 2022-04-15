# transparent-proxy-on-virtualbox

用VirtualBox创建一个透明代理虚拟机

<!-- https://guide.v2fly.org/en_US/app/transparent_proxy.html#pros -->

## 步骤 0, 安装服务器端

假设你已经完成了v2ray服务器端。

## 步骤 1, 安装依赖软件

在你的家庭服务器上，安装以下软件:

* git
* virtualbox
* vagrant
* ipcalc

## 步骤 2, 下载这个代码仓，配置并运行

以下命令将在你的家庭服务器内创建一台虚拟机，这台虚拟机可以被当做透明代理。

``` shell
$ git clone git@github.com:altiplanogao/transparent-proxy-on-virtualbox.git
$ cd transparent-proxy-on-virtualbox
$ # Create config file
$ cp config.ini.template config.ini
$ vi config.ini
$ # Run setup.sh script (Note: If an automatic restart is required, then you will be asked to enter the sudo password. That is to say, you needs to be in the sudoer list.)
$ ./setup.sh
```

Note: 安装脚本会自动下载两个v2ray相关工具，如果自动下载失败，请手动下载到'package'目录下。
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

通常的方法: 在路由器配置页面的dhcp配置项下，使用虚拟机的IP作为默认的网关。(在创建虚拟机时，其IP配置到了这里： config.ini -> $PROXY_IP)
```
$ #### Do the right thing to your router. ####
```

## 步骤 4, 完成 ...
将你的智能设备（电脑、手机、Pad……）连到你的路由器。

