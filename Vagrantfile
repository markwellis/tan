VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/debian-9"

    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 1
    end

    config.vm.hostname = "faketan.test"
    config.ssh.forward_agent = true
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.vm.network "private_network", ip: "192.168.55.21"

    config.vm.provision "shell",
        path: "vagrant/setup.sh",
        privileged: false

    #apache will fail to start on boot as the share isn't mounted yet
    config.vm.provision "shell",
      inline: "systemctl restart apache2 || true",
      run: "always"

    #make the vm fs faster but less safe
    config.vm.provision "shell",
      inline: "mount -o remount,nobarrier /",
      run: "always"
end
