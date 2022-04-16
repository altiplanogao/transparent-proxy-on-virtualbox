

check_if_running_as_root() {
  # If you want to run as another user, please modify $UID to be owned by this user
  if [[ "$UID" -ne '0' ]]; then
    echo "WARNING: The user currently executing this script is not root. You may encounter the insufficient privilege error."
    read -r -p "Are you sure you want to continue? [y/n] " cont_without_been_root
    if [[ x"${cont_without_been_root:0:1}" = x'y' ]]; then
      echo "Continuing the installation with current user..."
    else
      echo "Not running with root, exiting..."
      exit 1
    fi
  fi
}

trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  echo "$var"  
}

print_env() {
  echo -e "\n==============================\nPRINT ENV START\n=============================="
  env
  echo -e "==============================\nPRINT ENV END\n==============================\n"
}

expand_net_vars() {
    echo "EXPAND SETTING using \"${ROUTER_IP_MASKED}\""
    # will generate (by ipcalc using ${ROUTER_IP_MASKED})
    # LAN_NETWORK="10.1.0.0/16"
    # LAN_NETMASK=16
    # LAN_NETMASK_EXPAND="255.255.0.0"
    # ROUTER_IP="10.1.1.1"

    local lan_network=`ipcalc -n -b ${ROUTER_IP_MASKED} | grep Network | sed "s|Network:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
    if [ "${LAN_NETWORK}" = "" ] ; then
      LAN_NETWORK=`trim ${lan_network}`
    fi
    echo "  LAN_NETWORK: \"${LAN_NETWORK}\""

    local lan_netmask_str=`ipcalc -n -b ${ROUTER_IP_MASKED} | grep Netmask | sed "s|Netmask:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
    local lan_netmasks=(${lan_netmask_str//=/ }) 
    if [ "${LAN_NETMASK_EXPAND}" = "" ] ; then
      LAN_NETMASK_EXPAND=`trim ${lan_netmasks[0]}`
      LAN_NETMASK=`trim ${lan_netmasks[1]}`
    fi
    echo "  LAN_NETMASK_EXPAND: \"${LAN_NETMASK_EXPAND}\""
    echo "  LAN_NETMASK: \"${LAN_NETMASK}\""

    local router_ip=`ipcalc -n -b ${ROUTER_IP_MASKED} | grep Address | sed "s|Address:||g" | sed "s/^[[:space:]]*//g" | sed "s/[[:space:]]*$//g"`
    if [ "${ROUTER_IP}" = "" ] ; then
      ROUTER_IP=`trim ${router_ip}`
    fi
    echo "  ROUTER_IP: \"${ROUTER_IP}\""
}
