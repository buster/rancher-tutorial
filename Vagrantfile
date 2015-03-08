# -*- mode: ruby -*-
# # vi: set ft=ruby :

# This is fork of https://github.com/coreos/coreos-vagrant

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CONFIG = File.join(File.dirname(__FILE__), "vagrant", "config.rb")

# Defaults for config options defined in CONFIG
$update_channel = "alpha"
$expose_rancher_ui = 8080
$vb_gui = false
$vb_memory = 1024
$vb_cpus = 1
$rancheros_ip = "192.168.0.200"
$n_rancher = 1

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
    # plugin conflict
    if Vagrant.has_plugin?("vagrant-vbguest") then
      config.vbguest.auto_update = false
      config.vbguest.no_remote = true
    end

  config.vm.define :rancheros do |rancheros|
    rancheros.vm.box = "coreos-%s" % $update_channel
    rancheros.vm.box_version = ">= 308.0.1"
    rancheros.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

    rancheros.vm.provider :vmware_fusion do |vb, override|
      override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $update_channel
    end

    rancheros.vm.provider :virtualbox do |v|
      # On VirtualBox, we don't have guest additions or a functional vboxsf
      # in CoreOS, so tell Vagrant that so it can be smarter.
      v.check_guest_additions = false
      v.functional_vboxsf     = false
    end


      rancheros.vm.hostname = "rancher"

      rancheros.vm.network "forwarded_port", guest: 8080, host: $expose_rancher_ui, auto_correct: true

      rancheros.vm.provider :vmware_fusion do |vb|
        vb.gui = $vb_gui
      end

      rancheros.vm.provider :virtualbox do |vb|
        vb.gui = $vb_gui
        vb.memory = $vb_memory
        vb.cpus = $vb_cpus
      end

      config.vm.network "public_network", ip: $rancheros_ip

      rancheros.vm.provision :shell, run: "always", :inline => "docker run -d -p 8080:8080 rancher/server:latest", :privileged => true
      rancheros.vm.provision :shell, run: "always", :inline => "docker run -e CATTLE_AGENT_IP=%s -e WAIT=true -v /var/run/docker.sock:/var/run/docker.sock rancher/agent:latest http://%s:8080" % [$rancheros_ip, $rancheros_ip] , :privileged => true

  end

  (1..$n_rancher).each do |i|
    config.vm.define "rancher#{i}" do |rancher|

      rancher.vm.box       = "rancheros"
      rancher.vm.box_url   = "http://cdn.rancher.io/vagrant/x86_64/prod/rancheros_virtualbox.box"
      rancher.ssh.username = "rancher"

      rancher.vm.provider "virtualbox" do |vb|
        vb.check_guest_additions = false
        vb.functional_vboxsf     = false
        vb.memory = "1024"
        vb.gui = true
        #config.vm.network "private_network", :type => 'dhcp', :name => 'vboxnet0', :adapter => 2, auto_confi:false
        config.vm.network "public_network", ip: "192.168.0.20#{i}", auto_config: false, :adapter => 2
      end

      rancher.vm.synced_folder ".", "/vagrant", disabled: true

      rancher.vm.provision :shell, run: "always", :inline => "sudo sh -c \"echo -e 'auto lo\niface lo inet loopback\n\nauto eth1\niface eth1 inet static\n      address 192.168.0.20#{i}\n      netmask 255.255.255.0\n' > /etc/network/interfaces\""
      rancher.vm.provision :shell, run: "always", :inline => "sudo /etc/init.d/S40network restart"
      rancher.vm.provision :shell, run: "always", :inline => "docker run --rm -i --privileged -v /var/run/docker.sock:/var/run/docker.sock rancher/agent:latest http://%s:8080" % $rancheros_ip

    end

  end

end
