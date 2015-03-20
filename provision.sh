#!/bin/sh

set -e

DEBIAN_FRONTEND=noninteractive apt-get remove -y -f --purge ufw juju puppet chef ruby bundler xserver-xorg-core xserver-common x11-common xfonts-base apport default-jre || :
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y

apt-get install -y software-properties-common
apt-add-repository -y ppa:brightbox/ruby-ng
wget -qO - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y --force-yes build-essential zlib1g-dev autoconf binutils-doc bison flex gettext ncurses-dev
apt-get install -y --force-yes git nginx ruby2.2 ruby2.2-dev mysql-client-5.6 libmysqlclient-dev phantomjs openjdk-7-jre jenkins
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server-5.6 || :

echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
gem install bundler thor:0.19.0 busser:0.7.0 busser-serverspec:0.5.3 net-ssh:2.9.2 net-scp:1.2.1 specinfra:2.20.1 multi_json:1.11.0 diff-lcs:1.2.5 rspec-support:3.2.2 rspec-expectations:3.2.0 rspec-core:3.2.2 rspec-its:1.2.0 rspec-mocks:3.2.1 rspec:3.2.0 serverspec:2.10.1
gem_install="gem install --user-install rake:10.4.2 i18n:0.7.0 json:1.8.2 minitest:5.5.1 thread_safe:0.3.5 tzinfo:1.2.2 activesupport:4.2.0 builder:3.2.2 activemodel:4.2.0 arel:6.0.0 activerecord:4.2.0 colorize:0.7.5 net-ssh:2.9.2 net-scp:1.2.1 sshkit:1.7.1 capistrano:3.4.0 capistrano-bundler:1.1.4 capistrano-scm-copy:0.5.0 mime-types:2.4.3 mini_portile:0.6.2 nokogiri:1.6.6.2 rack:1.6.0 rack-test:0.6.3 xpath:2.0.0 capybara:2.4.4 cliver:0.3.2 diff-lcs:1.2.5 multi_json:1.11.0 gherkin:2.12.2 multi_test:0.1.2 cucumber:1.3.19 kgio:2.9.3 mysql2:0.3.18 websocket-extensions:0.1.2 websocket-driver:0.5.3 poltergeist:1.6.0 rack-flash3:1.0.5 rack-protection:1.5.3 raindrops:0.13.0 rspec-support:3.2.2 rspec-core:3.2.2 rspec-expectations:3.2.0 rspec-mocks:3.2.1 rspec:3.2.0 tilt:2.0.1 sinatra-activerecord:2.0.5 unicorn:4.8.3 bundler:1.8.5"
su vagrant -c "$gem_install"
su jenkins -c "$gem_install"

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
