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

  config.vagrant.plugins = "vagrant-hosts"

  vagrant_branch = ENV['PUPPET_ENV'] || 'production'

  config.vm.box = "almalinux/9"

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider :virtualbox do |vb|
    vb.auto_nat_dns_proxy = false
    vb.default_nic_type = "virtio"
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  config.vm.provision :shell, inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
      dnf -y install http://yum.puppet.com/puppet7-release-el-9.noarch.rpm
      dnf -y install puppet-agent
  SHELL

  config.vm.provision :hosts do |h|
    h.add_localhost_hostnames = false
    h.add_host '192.168.56.20', ['puppet.localdomain', 'puppet']
    h.add_host '192.168.56.21', ['node.localdomain', 'node']
  end

  # Puppet
  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet.localdomain"
    puppet.vm.network "private_network", ip: "192.168.56.20", virtualbox__intnet: "puppet"
    puppet.vm.network "forwarded_port", guest: 80,   host: 8000

    puppet.vm.provider "virtualbox" do |vb|
      vb.name   = "puppet"
      vb.memory = "4096"
      vb.cpus   = "2"
    end

    puppet.vm.provision "shell", run: "once", env: {"PUPPET_ENV" => vagrant_branch}, inline: <<-SHELL
      rm -rf /tmp/modules

      /opt/puppetlabs/bin/puppet module install \
      --environment production --modulepath=/tmp/modules \
      puppet/r10k

      # Broken faraday
      /opt/puppetlabs/puppet/bin/gem install --no-document faraday -v 2.8.1

      /opt/puppetlabs/bin/puppet apply \
      --environment production --modulepath=/tmp/modules \
      -e "class { 'r10k': remote => 'https://github.com/vchepkov/puppet-bootstrap.git' }"

      /opt/puppetlabs/bin/puppet apply \
      --environment production --modulepath=/tmp/modules \
      -e "file_line { 'mco': path=>'/root/.bashrc', line=>'alias mco=\\'sudo -u vagrant USER=vagrant /opt/puppetlabs/puppet/bin/mco\\''}"

      dnf -y install git-core

      /vagrant/bin/bootstrap.sh

      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    SHELL
  end

  # Node
  config.vm.define "node", autostart: false do |node|
    node.vm.hostname = "node.localdomain"
    node.vm.network "private_network", ip: "192.168.56.21", virtualbox__intnet: "puppet"

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "node"
      vb.memory = "1024"
    end

    node.vm.provision "shell", run: "once", inline: <<-SHELL
      /opt/puppetlabs/bin/puppet config set server puppet.localdomain --section main
      /opt/puppetlabs/bin/puppet config set environment #{vagrant_branch} --section agent
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
    SHELL
  end
end
