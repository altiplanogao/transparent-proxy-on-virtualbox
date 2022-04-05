# -*- mode: ruby -*-
# vi: set ft=ruby :

SUPPORTED_OS = {
  "ubuntu1604"          => {box: "generic/ubuntu1604",         user: "vagrant"},
  "ubuntu1804"          => {box: "generic/ubuntu1804",         user: "vagrant"},
  "ubuntu2004"          => {box: "generic/ubuntu2004",         user: "vagrant"},
}

$lan_ip = ENV['LAN_IP']
$bridge = ENV['BRIDGE_NAME']
$num_instances = 1
$vm_memory = 512
$vm_cpus = 1
$instance_name_prefix = "v2ray-proxy"
$os ||= "ubuntu2004"

host_vars = {}
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  $box = SUPPORTED_OS[$os][:box]
  config.vm.box_check_update = false

  max_id = $num_instances
  (1..max_id).each do |i|
    subip = 100 + i
    # ip = "#{$subnet}.#{subip}"
    # config.vm.define node_name = "%s-%02d" % [$instance_name_prefix, i] do |node|
    config.vm.define node_name = "%s-%02d" % [$instance_name_prefix, i] do |node|
      node.vm.hostname = node_name
      node.vm.box = $box

      # node.vm.network "private_network" , ip: "192.168.59.101"
      node.vm.network "public_network" , ip:$lan_ip , bridge: $bridge

      node.vm.provider "virtualbox" do |v|
        v.name = node_name
        v.cpus = $vm_cpus
        v.memory = $vm_memory
      end
      # copy private key so hosts can ssh using key authentication (the script below sets permissions to 600)
      node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "host_id_rsa.pub"
      node.vm.provision "file", source: "package", destination: "$HOME/"
      node.vm.provision "file", source: "vm_templates.resolved", destination: "$HOME/"
      node.vm.provision "shell", path: "scripts/vm/login_disable_password.sh"
      node.vm.provision "shell", path: "scripts/vm//login_enable_key.sh", privileged: false
      node.vm.provision "shell", path: "scripts/vm//bootstrap.sh"
    end
  end
end
