# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = "2"
    vb.memory = "1024"
  end

  config.vm.provision "shell", path: "provision.sh"

  config.push.define "local", strategy: "local-exec" do |push|
      push.inline = "vagrant package --output devops-jumpstart.box"
  end

  config.push.define "remote", strategy: "atlas" do |push|
      push.app = "xpeppers/devops-jumpstart"
  end
end
