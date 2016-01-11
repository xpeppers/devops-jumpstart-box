#!/bin/sh

set -e

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys

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

curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.5.1;

echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
global_gems="bundler capistrano capistrano-scm-copy capistrano-bundler"
user_gems="rake:10.4.2 i18n:0.7.0 json:1.8.3 minitest:5.8.2 thread_safe:0.3.5 tzinfo:1.2.2 activesupport:4.2.4 builder:3.2.2 activemodel:4.2.4 arel:6.0.3 activerecord:4.2.4  mime-types:2.6.2 mini_portile:0.6.2 nokogiri:1.6.6.2 rack:1.6.4 rack-test:0.6.3 xpath:2.0.0 capybara:2.5.0 cliver:0.3.2 diff-lcs:1.2.5 multi_json:1.11.2 gherkin3:3.1.2 multi_test:0.1.2 cucumber:2.1.0 kgio:2.10.0 mysql2:0.3.20 websocket-extensions:0.1.2 websocket-driver:0.6.3 poltergeist:1.7.0 rack-flash3:1.0.5 rack-protection:1.5.3 raindrops:0.15.0 rspec-support:3.3.0 rspec-core:3.3.2 rspec-expectations:3.3.1 rspec-mocks:3.3.2 rspec:3.3.0 tilt:2.0.1 sinatra-activerecord:2.0.9 unicorn:5.0.0"
gem install $global_gems
su vagrant -c "gem install --user-install --no-rdoc --no-ri $user_gems"
su jenkins -c "gem install --user-install --no-rdoc --no-ri $user_gems"

BUSSER_ROOT=/tmp/verifier
GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache /opt/chef/embedded/bin/
GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache /opt/chef/embedded/bin/
GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache $BUSSER_ROOT/gems/bin/b
GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache $BUSSER_ROOT/gems/bin/b
chmod -R 777 $BUSSER_ROOT

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
