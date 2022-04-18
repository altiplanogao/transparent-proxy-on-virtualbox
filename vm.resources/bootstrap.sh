#!/usr/bin/env bash
# set -o errexit

echo "BASEDIR @: \"${BASEDIR}\""
if [ -z ${BASEDIR} ]; then
    BASEDIR=$(dirname "$0")
    echo "BASEDIR @: \"${BASEDIR}\""
fi

WD="${BASEDIR}"

. ${WD}/config.sh
SD=${WD}/scripts
. ${SD}/common.sh
. ${SD}/handle_generic.sh
. ${SD}/handle_v2ray.sh
. ${SD}/handle_templates.sh
. ${SD}/handle_network.sh
. ${SD}/handle_iptables.sh
TPL_DIR=${WD}/templates
TPL_RESOLVED_DIR=${WD}/templates.resolved

install_deb_pkgs

install_dependency_tools

expand_net_vars

check_network

ensure_default_route_exist

resolve_templates

install_and_start_v2ray

enable_ip_forwading

config_ip_rules

config_iptable_autostart
