# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "devops-jumpstart"
  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 9000, host: 9000
  config.vm.network :forwarded_port, guest: 10000, host: 10000
  config.vm.network :forwarded_port, guest: 11000, host: 11000

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = "2"
    vb.memory = "3072"
  end

  config.vm.provision "shell", path: "provision.sh"

  config.push.define "local", strategy: "local-exec" do |push|
    push.inline = "vagrant package --output devops-jumpstart.box"
  end

  config.push.define "remote", strategy: "atlas" do |push|
    push.app = "xpeppers/devops-jumpstart"
  end
end
