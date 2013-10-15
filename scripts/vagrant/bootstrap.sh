#!/usr/bin/env bash

if [ -f /home/vagrant/installed ]; then
  echo "Setup already completed.. skipping. To run this again, remove /home/vagrant/installed"
  exit 0
fi

update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10
update-alternatives --set python /usr/bin/python2.7
# get additional repos
apt-get update
apt-get install -y python-software-properties
add-apt-repository -y ppa:fkrull/deadsnakes
add-apt-repository -y ppa:chris-lea/node.js
add-apt-repository -y ppa:chris-lea/redis-server

# install stuff
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get install -y python2.6 python2.6-dev mysql-client-5.5 mysql-server-5.5 memcached libmysqlclient-dev curl openjdk-7-jre-headless build-essential
apt-get install -y libxml2 libxml2-dev libxslt1.1 libxslt1-dev libjpeg8-dev zlib1g zlib1g-dev
apt-get install -y nodejs tmux redis-server pv vim unzip
# apt-get dist-upgrade -y

# fix problems so PIL can compile
ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib

# removed so that it doesn't complain that some py module is not found as we
# are using py26
apt-get purge -y command-not-found

# setup python2.6
update-alternatives --install /usr/bin/python python /usr/bin/python2.6 1000
update-alternatives --set python /usr/bin/python2.6

python --version

# setup node
ln -sf /usr/bin/nodejs /usr/bin/node

cd /tmp

# install elastic search
curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.5.deb
dpkg -i elasticsearch*.deb
rm elasticsearch*.deb

# install pip
wget https://pypi.python.org/packages/source/d/distribute/distribute-0.7.3.zip
unzip distribute-0.7.3.zip
cd distribute-0.7.3
python setup.py install
easy_install pip

pip install virtualenv
cd /kitsune
pip install -r requirements/compiled.txt
rm /kitsune/build -rf

# setup mysql

mysqladmin -u root password helloworld
echo "CREATE DATABASE kitsune; GRANT ALL ON kitsune.* TO kitsune@localhost IDENTIFIED BY 'kitsune'" | mysql -u root --password=helloworld

# redis stuff
mkdir -p /home/vagrant/kitsune-redis/sumo
mkdir -p /home/vagrant/kitsune-redis/sumo-test
mkdir -p /home/vagrant/kitsune-redis/sumo-persistent
chown -R vagrant:vagrant /home/vagrant/kitsune-redis

# install less
npm install -g less

# Fix locale issue
echo "export LANG=en_US.UTF-8" >> /home/vagrant/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> /home/vagrant/.bashrc

# convenience
echo "alias t=\"./manage.py test -s --noinput --logging-clear-handlers --with-id\"" >> /home/vagrant/.bashrc
echo "cd /kitsune" >> /home/vagrant/.bashrc
echo "bash /kitsune/scripts/vagrant/start_redis" >> /home/vagrant/.bashrc

touch /home/vagrant/installed

cd /kitsune
./scripts/vagrant/start_redis
echo "Running unittests.. please wait"
./manage.py test -s --noinput --logging-clear-handlers --with-id

echo "Please run ./manage.py syncdb --migrate for a new database!"
