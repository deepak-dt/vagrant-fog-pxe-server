# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
vagrant_config = YAML.load_file("provisioning/virtualbox.conf.yml")

Vagrant.configure("2") do |config|

  config.vm.box = vagrant_config['box']
  
  #if Vagrant.has_plugin?("vagrant-cachier")
  #  # Configure cached packages to be shared between instances of the same base box.
  #  # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
  #  config.cache.scope = :box
  #end

  # Bring up the Devstack controller node on Virtualbox
  config.vm.define "pxe_server_vm" do |pxe_server_vm|
    pxe_server_vm.vm.provision :shell, path: "provisioning/setup-pxe-server.sh", privileged: false, args: [vagrant_config['pxe_server_vm']['git_email'], vagrant_config['pxe_server_vm']['git_username'], vagrant_config['pxe_server_vm']['git_password']] 

    config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true

      # Customize the amount of memory on the VM:
      vb.memory = vagrant_config['pxe_server_vm']['memory']
      vb.cpus = vagrant_config['pxe_server_vm']['cpus']

      # Configure external provide network in VM
      config.vm.network "private_network", ip: vagrant_config['pxe_server_vm']['provider_ip']
    end
  end
  
  #config.vm.provision "file", source: "ubuntu-16.04.3-server-amd64.iso", destination: "/home/vagrant/ubuntu-16.04.3-server-amd64.iso"

  config.vm.synced_folder '.', '/vagrant'

end
