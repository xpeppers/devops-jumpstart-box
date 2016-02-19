# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "devops-jumpstart"
  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 9000, host: 9000
  config.vm.network :forwarded_port, guest: 10000, host: 10000
  config.vm.network :forwarded_port, guest: 11000, host: 11000
  config.vm.network :forwarded_port, guest: 5601, host: 5601
  config.vm.network :forwarded_port, guest: 2000, host: 2000
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provider "virtualbox" do |vb|
    vb.name = "devops-jumpstart"
    vb.cpus = "2"
    vb.memory = "4096"
  end

  config.vm.provision "shell", path: "provision.sh"
end
