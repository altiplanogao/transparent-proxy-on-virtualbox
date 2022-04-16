# -*- mode: ruby -*-
# vi: set ft=ruby :

SUPPORTED_OS = {
  "ubuntu1604"          => {box: "generic/ubuntu1604",         user: "vagrant"},
  "ubuntu1804"          => {box: "generic/ubuntu1804",         user: "vagrant"},
  "ubuntu2004"          => {box: "generic/ubuntu2004",         user: "vagrant"},
}

$lan_ip = ENV['PROXY_IP']
$bridge = ENV['BRIDGE_NAME']
$net_mask = ENV['LAN_NETMASK_EXPAND']
$router_ip=ENV['ROUTER_IP']
$proxy_vm_name=ENV['VM_NAME']
$vm_memory = 512
$vm_cpus = 1
$os ||= "ubuntu2004"

puts "Vagrantfile vm name: %s" % $proxy_vm_name
host_vars = {}
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  $box = SUPPORTED_OS[$os][:box]
  config.vm.box_check_update = false

  # config.vm.define node_name = "%s-%02d" % [$instance_name_prefix, i] do |node|
  config.vm.define node_name = "%s" % [$proxy_vm_name] do |node|
    node.vm.hostname = $proxy_vm_name
    node.vm.box = $box

    # node.vm.network "private_network" , ip: "192.168.59.101"
    node.vm.network "public_network" , ip:$lan_ip , bridge: $bridge , netmask:$net_mask

    node.vm.provider "virtualbox" do |v|
      v.name = node_name
      v.cpus = $vm_cpus
      v.memory = $vm_memory
      v.customize ["modifyvm", :id, "--vram", "8"] # ubuntu defaults to 256 MB which is a waste of precious RAM
      v.customize ["modifyvm", :id, "--audio", "none"]
    end

    # copy private key so hosts can ssh using key authentication (the script below sets permissions to 600)
    node.vm.provision "file", source: "~/.ssh/authorized_keys", destination: ".ssh/authorized_keys"
    node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "host_id_rsa.pub"
    node.vm.provision "file", source: "vm.resources.suite", destination: "$HOME/resources"

    $script = "
    netplan set ethernets.eth1.dhcp4=false
    netplan set ethernets.eth1.gateway4=%s
    netplan apply" % $router_ip
    # $script = <<-'SCRIPT'
    # netplan set ethernets.eth1.dhcp4=false
    # netplan set ethernets.eth1.gateway4=${router_ip}
    # netplan apply
    # SCRIPT
    puts "will execute shell: %s" % $script
    node.vm.provision "shell", inline: $script

    # node.vm.provision "shell", path: "scripts/vm/system_initialize.sh"
    node.vm.provision "shell", path: "scripts/vm/bootstrap_entry.sh"
    node.vm.provision "shell", path: "scripts/vm/login_enable_key.sh", privileged: false
    node.vm.provision "shell", path: "scripts/vm/login_disable_password.sh"
  end
end
