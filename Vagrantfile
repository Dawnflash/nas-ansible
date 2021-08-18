Vagrant.configure(2) do |config|
  config.vm.define "ansible-nas-test" do
    config.vm.box = "debian/bullseye64"
    config.vm.network "private_network", ip: "172.10.0.2"
    # Experimental feature: set VAGRANT_EXPERIMENTAL=disk
    config.vm.disk :disk, name: "storage", size: "1GB"

    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus   = 2
    end

    config.vm.provision "ansible" do |ansible|
      ansible.inventory_path = "inventories/local/inventory.yml"
      ansible.playbook = "nas.yml"
      ansible.become = true
    end
  end
end
