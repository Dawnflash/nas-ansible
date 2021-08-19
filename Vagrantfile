Vagrant.configure(2) do |config|
  config.vm.define "ansible-nas-test" do
    config.vm.box = "debian/bullseye64"
    config.vm.network "private_network", ip: "172.10.0.2"

    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus   = 2
      v.customize [ 'storageattach', :id,
                    '--storagectl', 'SATA Controller',
                    '--port', 1,
                    '--device', 0,
                    '--type', 'hdd',
                    '--medium', '.vagrant/test_zdisk.vdi' ]
    end

    config.vm.provision "ansible" do |ansible|
      ansible.inventory_path = "inventories/local/inventory.yml"
      ansible.playbook = "nas.yml"
    end

    config.trigger.after :halt do |trigger|
      trigger.info = "Detaching persistent drive"
      trigger.ruby do |env,machine|
        puts `VBoxManage storageattach '#{machine.id}' --storagectl 'SATA Controller' --port 1 --device 0 --type hdd --medium none`
      end
    end
  end
end
