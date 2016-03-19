#!/usr/bin/env bash

# Function to issue sudo command with password
function sudo-pw {
    echo "vagrant" | sudo -S $@
}

# Update your system
sudo-pw apt-get -y update
sudo-pw apt-get -y upgrade

# Install prerequisites
sudo-pw apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
sudo-pw apt-get -y install git curl vim
sudo-pw apt-get -y install libreadline-gplv2-dev


if [ ! $(which rbenv) ]; then
  echo "
export RBENV_ROOT=\"\${HOME}/.rbenv\"
if [ -d \"\${RBENV_ROOT}\" ]; then
  export PATH=\"\${RBENV_ROOT}/bin:\${PATH}\"
  eval \"\$(rbenv init -)\"
fi
" >> ~/.bashrc
fi

source ~/.bashrc

export RBENV_ROOT="${HOME}/.rbenv"
export PATH="${RBENV_ROOT}/bin:${PATH}"

cd ~
curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash

rbenv install 2.3.0
rbenv rehash
rbenv global 2.3.0

cd  ~/.rbenv  # rbenv install location (...or /opt/rbenv/)
git pull # will pull rbenv repo

cd plugins/ruby-build/
git pull # will pull recent ruby builds

# Install bundler (gem manager)
sudo-pw gem install bundler

# Install mysql
sudo-pw apt-get -y install mysql-server
sudo-pw apt-get install libmysqlclient-dev
sudo-pw apt-get -y install ruby1.9.1-dev
gem install mysql2

sudo-pw apt-get -y install nodejs

# install hh history tool
sudo-pw add-apt-repository ppa:ultradvorka/ppa
sudo-pw apt-get update
sudo-pw apt-get install hh

sudo-pw apt-get install libncurses5-dev libreadline-dev
wget https://github.com/dvorka/hstr/releases/download/1.10/hh-1.10-src.tgz
tar xf hh-1.10-src.tgz
cd hstr
./configure && make && sudo-pw make install