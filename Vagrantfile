# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.0.0"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  vagrant_branch = ENV['PUPPET_ENV'] || 'production'

  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest plugin is not installed!'
  end
  config.vbguest.auto_update = true
  config.vbguest.auto_reboot = true

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box      = "centos/7"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider :virtualbox do |vb|
    vb.auto_nat_dns_proxy = false
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end

  # Master
  config.vm.define "master", primary: true do |master|
    master.vm.hostname = "master.localdomain"
    master.vm.network "private_network", ip: "192.168.50.20"
    master.vm.network "forwarded_port", guest: 80,   host: 8000
    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 8140, host: 8140

    master.vm.provider "virtualbox" do |vb|
      vb.name   = "master"
      vb.memory = "4096"
      vb.cpus   = "2"
    end

    master.vm.provision "shell", run: "once", env: {"PUPPET_ENV" => vagrant_branch}, inline: <<-SHELL
      systemctl mask firewalld
      systemctl stop firewalld
      yum -y install http://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm
      yum -y install puppet-agent

      /opt/puppetlabs/bin/puppet module install \
      --environment production --modulepath=/var/tmp/modules \
      puppet-r10k

      /opt/puppetlabs/bin/puppet apply \
      --environment production --modulepath=/var/tmp/modules \
      -e "class { 'r10k': remote => 'file:///vagrant/' }"

      /vagrant/examples/bootstrap.sh
    SHELL
  end

  # Node
  config.vm.define "node", autostart: false do |node|
    node.vm.hostname = "node.localdomain"
    node.vm.network "private_network", ip: "192.168.50.21"

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "node"
      vb.memory = "1024"
    end

    node.vm.provision "shell", run: "once", inline: <<-SHELL
      systemctl mask firewalld
      systemctl stop firewalld
      yum -y install http://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm
      yum -y install puppet-agent
      /opt/puppetlabs/bin/puppet resource host master.localdomain ip=192.168.50.20
      /opt/puppetlabs/bin/puppet config set server master.localdomain --section agent
      /opt/puppetlabs/bin/puppet config set environment #{vagrant_branch} --section agent
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    SHELL
  end
end
