RUBYOPT='-W:no-deprecated' RAILS_ENV=development bundle exec thin start --ssl --ssl-key-file server.key --ssl-cert-file server.crt -p 9292 --debug
