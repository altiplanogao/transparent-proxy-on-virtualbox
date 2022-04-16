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

## 步骤 4, 完成 ...
将你的智能设备（电脑、手机、Pad……）连到你的路由器。

---

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

