Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  # config.vm.synced_folder "~/code-workout", "/home/vagrant/code-workout"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
end
