Vagrant.configure(2) do |config|
  config.vm.define "ansible-nas-test" do
    config.vm.box = "debian/bullseye64"
    config.vm.network "private_network", ip: "172.10.0.2"

    config.vm.provision "ansible_local" do |ansible|
      ansible.inventory_path = "inventories/local/inventory.yml"
      ansible.playbook = "nas.yml"
      ansible.become = true
    end
  end
end
