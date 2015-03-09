#!/bin/sh

apt-get remove -y --purge ufw juju puppet chef ruby bundler
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y

apt-get install -y build-essential zlib1g-dev software-properties-common git
apt-add-repository -y ppa:brightbox/ruby-ng
apt-get update -y
apt-get install -y ruby2.2 ruby2.2-dev
echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.1.0;

umount /vagrant

apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y

find /var/lib/apt -type f | xargs rm -f
find /var/log -type f | while read f; do echo -ne '' > $f; done;
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest* /usr/src/virtualbox-guest*
rm -rf /usr/src/linux-headers*

unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

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
