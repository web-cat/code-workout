cd /vagrant
# thin start -e debugging --ssl --ssl-key-file server.key --ssl-cert-file server.crt -p 3000 --debug
thin start -e debugging -p 3000 --debug
