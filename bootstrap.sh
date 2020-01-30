# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo adding swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

echo updating system packages
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential  dkms curl libxslt-dev libpq-dev python-dev python-pip python-feedvalidator python-software-properties python-sphinx libmariadbclient-dev libcurl4-gnutls-dev libevent-dev libffi-dev libssl-dev stunnel4 libsqlite3-dev libgmp3-dev

install Ruby ruby2.3 ruby2.3-dev
update-alternatives --set ruby /usr/bin/ruby2.3>/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.3>/dev/null 2>&1

echo installing Bundler
gem install bundler -v 1.17.3 -N >/dev/null 2>&1

install Git git

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
mysql -uroot -proot <<SQL
CREATE DATABASE codeworkout DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON codeworkout.* to 'codeworkout'@'localhost' IDENTIFIED BY 'codeworkout';
FLUSH PRIVILEGES;
SQL

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs npm uglifyjs
curl -sL https://deb.nodesource.com/setup | sudo bash -
ln -s /usr/bin/nodejs /usr/bin/node
ln -s /usr/bin/nodejs /usr/sbin/node
npm install -g jshint
npm install -g csslint
npm install -g bower

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

# install hh tool
sudo apt-add-repository -y ppa:ultradvorka/ppa
sudo apt-get update
sudo apt-get install -y hh

sudo apt-get install -y libncurses5-dev libreadline-dev
wget https://github.com/dvorka/hstr/releases/download/1.10/hh-1.10-src.tgz
tar xf hh-1.10-src.tgz
cd hstr
./configure && make && sudo make install

hh --show-configuration >> ~/.bashrc
source ~/.bashrc

# install Java 8 and Ant
sudo apt-add-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y ant

#Install Docker CE
echo installing docker
sudo apt-get update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce
sudo groupadd docker
sudo usermod -aG docker vagrant

#Add docker images
echo getting docker images
sudo docker pull codeworkout/cpp
sudo docker pull codeworkout/python
sudo docker pull codeworkout/ruby

cd /vagrant
bundle install
rake db:reset
rake db:populate

echo 'all set, welcome to CodeWorkout project!'
