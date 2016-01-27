#!/bin/sh

set -e

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update -y && apt-get upgrade -y
apt-get install -y vim linux-image-extra-$(uname -r) docker-engine openbox lxterminal xinit x11-xserver-utils

curl -o /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb && dpkg -i /tmp/vagrant.deb && rm -rf /tmp/vagrant.deb
vagrant plugin install vagrant-berkshelf
usermod -a -G docker vagrant

curl -o /tmp/chefdk.deb https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/14.04/x86_64/chefdk_0.10.0-1_amd64.deb && dpkg -i /tmp/chefdk.deb && rm -rf /tmp/chefdk.deb
/opt/chefdk/embedded/bin/chef gem install kitchen-docker

echo "xrandr --auto --primary --mode 1024x768" > /home/vagrant/.xprofile

cd /vagrant
docker rmi -f $(docker images -q) || true
docker build -t xpeppers/devops-jumpstart ./

if [ ! -d "/vagrant/devops-jumpstart" ]; then
  su vagrant -c "git clone https://github.com/xpeppers/devops-jumpstart.git"
else
  su vagrant -c "git pull"
fi

umount /vagrant

apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

find /var/lib/apt -type f | xargs rm -f
find /var/log -type f | while read f; do echo -ne '' > $f; done;
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest* /usr/src/virtualbox-guest*
rm -rf /usr/src/linux-headers*

unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

set +e

count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
