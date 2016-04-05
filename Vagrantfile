Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder "/home/hshahin/workspaces/sites", "/home/vagrant/sites"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "forwarded_port", guest: 3306, host: 9306
  config.vm.synced_folder "~/workspaces/sites", "/home/vagrant/sites"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4048"
  end
end
