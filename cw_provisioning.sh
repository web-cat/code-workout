#!/usr/bin/env bash

# Function to issue sudo command with password
function sudo-pw {
    echo "vagrant" | sudo -S $@
}

# Update your system
sudo-pw apt-get -y update
sudo-pw apt-get -y upgrade

# Install prerequisites
sudo-pw apt-get -y install git-core curl vim zlib1g-dev build-essential libssl-dev libreadline-dev libreadline-gplv2-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev mysql-server ruby1.9.1-dev nodejs

# follow instructions here to install rbenv
# http://www.eq8.eu/blogs/4-installing-rbenv-on-ubuntu-machine
cd ~
curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash

# vim ~/.bashrc
# and add
# export RBENV_ROOT="${HOME}/.rbenv"
# # export RBENV_ROOT="/opt/rbenv/" # some developers prefare this option I highly recommend
#                                   # to instal rbenv to home folder of deploy user as it's
#                                   # convention

# if [ -d "${RBENV_ROOT}" ]; then
#   export PATH="${RBENV_ROOT}/bin:${PATH}"
#   eval "$(rbenv init -)"
# fi


# Show help if `.rbenv` is not in the path:
if [ ! $(which rbenv) ]; then
  echo "
export RBENV_ROOT=\"\${HOME}/.rbenv\"
if [ -d \"\${RBENV_ROOT}\" ]; then
  export PATH=\"\${RBENV_ROOT}/bin:\${PATH}\"
  eval \"\$(rbenv init -)\"
fi
" >> ~/.bashrc
fi

. ~/.bashrc

rbenv install 2.3.0
rbenv rehash
rbenv global 2.3.0
rbenv version

cd  ~/.rbenv  # rbenv install location (...or /opt/rbenv/)
git pull # will pull rbenv repo

cd plugins/ruby-build/
git pull # will pull recent ruby builds

rbenv rehash
# To update ruby-gem
gem update --system
# Install bundler (gem manager)
gem install bundler
bundle install
# (After any gem or ruby version installation)
rbenv rehash
# Install rails
gem install rails --no-ri --no-rdoc
gem list

gem install mysql2