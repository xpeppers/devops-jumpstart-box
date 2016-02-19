FROM ubuntu:14.04

RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y -f --purge ufw puppet ruby default-jre || :
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl apt-transport-https

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C3173AA6 && echo 'deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main' > /etc/apt/sources.list.d/ruby.list
RUN curl http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - && echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list
RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - && echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' > /etc/apt/sources.list.d/elasticsearch.list
RUN echo 'deb http://packages.elasticsearch.org/logstash/2.2/debian stable main' > /etc/apt/sources.list.d/logstash.list
RUN echo 'deb http://packages.elastic.co/kibana/4.4/debian stable main' > /etc/apt/sources.list.d/kibana.list
RUN echo 'deb http://packages.elastic.co/beats/apt stable main' > /etc/apt/sources.list.d/beats.list
RUN curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add - && echo 'deb http://www.rabbitmq.com/debian testing main' > /etc/apt/sources.list.d/rabbitmq.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12 && echo 'deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu trusty main' > /etc/apt/sources.list.d/redis.list
RUN curl https://repos.influxdata.com/influxdb.key | apt-key add - && echo 'deb http://repos.influxdata.com/debian jessie stable' > /etc/apt/sources.list.d/influxdb.list
RUN curl http://repos.sensuapp.org/apt/pubkey.gpg | sudo apt-key add - && echo 'deb http://repos.sensuapp.org/apt sensu main' > /etc/apt/sources.list.d/sensu.list
RUN curl https://packagecloud.io/gpg.key | apt-key add - && echo 'deb http://packagecloud.io/grafana/stable/debian wheezy main' > /etc/apt/sources.list.d/grafana.list
RUN apt-get update -y
RUN apt-get install -y --force-yes openssh-server sudo lsb-release build-essential zlib1g-dev autoconf binutils-doc bison flex gettext ncurses-dev git nginx ruby2.2 ruby2.2-dev mysql-client-5.6 libmysqlclient-dev phantomjs openjdk-7-jre-headless jenkins elasticsearch logstash kibana filebeat rabbitmq-server redis-server sensu uchiwa
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes mysql-server-5.6 || :

RUN curl -L https://www.chef.io/chef/install.sh | bash

RUN useradd --create-home --shell /bin/bash vagrant
RUN echo vagrant:vagrant | chpasswd

ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN chmod 0600 /home/vagrant/.ssh/authorized_keys
RUN chmod 0700 /home/vagrant/.ssh
RUN curl -o /home/vagrant/.ssh/id_rsa http://download.xpeppers.com/devops-jumpstart.pem
RUN chmod 0600 /home/vagrant/.ssh/id_rsa
RUN echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01_vagrant
RUN chmod 0400 /etc/sudoers.d/01_vagrant

ENV global_gems="bundler capistrano capistrano-scm-copy capistrano-bundler sensu-plugins-cpu-checks sensu-plugins-disk-checks sensu-plugins-nginx"
ENV user_gems="rake:10.4.2 i18n:0.7.0 json:1.8.3 minitest:5.8.2 thread_safe:0.3.5 tzinfo:1.2.2 activesupport:4.2.4 builder:3.2.2 activemodel:4.2.4 arel:6.0.3 activerecord:4.2.4  mime-types:2.6.2 mini_portile:0.6.2 nokogiri:1.6.6.2 rack:1.6.4 rack-test:0.6.3 xpath:2.0.0 capybara:2.5.0 cliver:0.3.2 diff-lcs:1.2.5 multi_json:1.11.2 gherkin3:3.1.2 multi_test:0.1.2 cucumber:2.1.0 kgio:2.10.0 mysql2:0.3.20 websocket-extensions:0.1.2 websocket-driver:0.6.3 poltergeist:1.7.0 rack-flash3:1.0.5 rack-protection:1.5.3 raindrops:0.15.0 rspec-support:3.3.0 rspec-core:3.3.2 rspec-expectations:3.3.1 rspec-mocks:3.3.2 rspec:3.3.0 tilt:2.0.1 sinatra:1.4.6 sinatra-activerecord:2.0.9 unicorn:5.0.0"

RUN echo 'gem: --no-rdoc --no-ri' > /etc/gemrc
RUN gem install $global_gems
RUN su vagrant -c "gem install --user-install --no-rdoc --no-ri $user_gems"
RUN su jenkins -c "gem install --user-install --no-rdoc --no-ri $user_gems"
RUN /opt/sensu/embedded/bin/gem install em-http-request

ENV BUSSER_ROOT /tmp/verifier

RUN GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache /opt/chef/embedded/bin/gem install busser --no-rdoc --no-ri
RUN GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache /opt/chef/embedded/bin/gem install serverspec --no-rdoc --no-ri
RUN GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache $BUSSER_ROOT/gems/bin/busser setup
RUN GEM_HOME=$BUSSER_ROOT/gems GEM_PATH=$BUSSER_ROOT/gems GEM_CACHE=$BUSSER_ROOT/gems/cache $BUSSER_ROOT/gems/bin/busser plugin install busser-serverspec
RUN chmod -R 777 $BUSSER_ROOT

RUN apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y && find /var/lib/apt -type f | xargs rm -f

RUN mkdir /var/run/sshd
CMD ["/usr/sbin/sshd", "-D", "-e"]
EXPOSE 22
