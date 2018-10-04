if [ -d /vagrant ]
then
  cd /vagrant
fi
thin start --ssl --ssl-key-file server.key --ssl-cert-file server.crt -p 9292 --debug
