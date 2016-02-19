#!/bin/sh

set -e

DEBIAN_FRONTEND=noninteractive apt-get remove -y -f --purge ufw juju puppet chef ruby bundler apport default-jre plymouth apparmor || :

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update -y && apt-get upgrade -y
apt-get install -y unzip linux-image-extra-$(uname -r) docker-engine openbox lxterminal xinit x11-xserver-utils

curl -o /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb && dpkg -i /tmp/vagrant.deb && rm -rf /tmp/vagrant.deb
vagrant plugin install vagrant-berkshelf
usermod -a -G docker vagrant
usermod -a -G vboxsf vagrant

curl -o /tmp/chefdk.deb https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/14.04/x86_64/chefdk_0.10.0-1_amd64.deb && dpkg -i /tmp/chefdk.deb && rm -rf /tmp/chefdk.deb
/opt/chefdk/embedded/bin/chef gem install kitchen-docker

curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip && unzip /tmp/packer.zip -d /usr/local/bin && rm -f /tmp/packer.zip
curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.6.11/terraform_0.6.11_linux_amd64.zip&& unzip /tmp/terraform.zip -d /usr/local/bin && rm -f /tmp/terraform.zip

curl -o /tmp/awscli.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip  && unzip /tmp/awscli.zip -d /tmp
/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && rm -rf /tmp/awscli.zip && rm -rf /tmp/awscli-bundle

echo "xrandr --auto --primary --mode 1024x768" > /home/vagrant/.xprofile

cd /vagrant
docker rmi -f $(docker images -q) || true
docker build -t xpeppers/devops-jumpstart ./

docker save xpeppers/devops-jumpstart > image.tar
./docker-squash -i image.tar -o squashed.tar
cat squashed.tar | docker load
docker images xpeppers/devops-jumpstart
rm *.tar

ntpdate europe.pool.ntp.org

cd /
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
