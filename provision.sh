#!/bin/sh

apt-get remove -y --purge ufw juju puppet chef ruby bundler xserver-xorg-core xserver-common x11-common xfonts-base apport
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y

apt-get install -y software-properties-common
apt-add-repository -y ppa:brightbox/ruby-ng
wget -qO - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y build-essential zlib1g-dev autoconf binutils-doc bison flex gettext ncurses-dev
apt-get install -y git ruby2.2 ruby2.2-dev mysql-server-5.6 mysql-client-5.6 libmysqlclient-dev  phantomjs openjdk-7-jre jenkins
echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
gem install bundler rack:1.6.0 rack-protection:1.5.3 tilt:2.0.1 sinatra-activerecord:2.0.5 mysql2:0.3.18 rake:10.4.2 rack-flash3:1.0.5 unicorn:4.8.3 rspec:3.2.0  rack-test:0.6.3 cucumber:1.3.19 capybara:2.4.4 poltergeist:1.6.0
su jenkins -c "gem install --user-install rack:1.6.0 rack-protection:1.5.3 tilt:2.0.1 sinatra-activerecord:2.0.5 mysql2:0.3.18 rake:10.4.2 rack-flash3:1.0.5 unicorn:4.8.3 rspec:3.2.0  rack-test:0.6.3 cucumber:1.3.19 capybara:2.4.4 poltergeist:1.6.0"
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
