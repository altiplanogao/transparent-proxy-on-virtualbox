#!/usr/bin/env bash

ROUTER_IP='x.x.x.x'
LAN_IP='x.x.x.x'
BRIDGE_NAME="xxx"

bridge_names=`VBoxManage list bridgedifs | grep Name | grep -v VBoxNetworkName`
bridge_ips=`VBoxManage list bridgedifs | grep IPAddress`

echo ${bridge_names}

echo ${bridge_ips}

export LAN_IP
export BRIDGE_NAME

vagrant destroy -f && vagrant up