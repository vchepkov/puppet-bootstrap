# Configure puppet master
class bootstrap::master (
  String $puppet_master                  = 'master.localdomain',
  Optional[Array[String]] $dns_alt_names = undef,
  Boolean $autosign                      = true,
  Optional[String] $environment          = undef,
) {

  package { 'postgresql-module':
    ensure   => disabled,
    name     => 'postgresql',
    provider => 'dnfmodule',
  }

  class { 'puppetdb::database::postgresql':
    manage_package_repo => true,
    postgres_version    => '11',
    before              => Class['puppetdb::server'],
    require             => Package['postgresql-module'],
  }

  class { 'puppetdb::server':
    listen_port             => '8080',
    manage_firewall         => false,
    disable_update_checking => true,
  }

  class { 'puppet::server::puppetdb':
    server => $puppet_master,
  }

  class { 'puppet':
    autosign            => $autosign,
    dns_alt_names       => $dns_alt_names,
    environment         => $environment,
    hiera_config        => "${settings::confdir}/hiera.yaml",
    server              => true,
    server_foreman      => false,
    server_reports      => 'puppetdb',
    server_storeconfigs => true,
    puppetmaster        => $puppet_master,
  }

  # Don't start agent until master is configured
  Service['puppetserver'] -> Service['puppet']

  systemd::dropin_file { 'local.conf':
    unit   => 'puppet.service',
    source => "puppet:///modules/${module_name}/puppet-systemd.conf",
  }

  # workaround for choria expecting puppet in PATH
  file { '/usr/bin/puppet':
    ensure  => 'link',
    target  => '/opt/puppetlabs/bin/puppet',
    seltype => 'puppetagent_exec_t',
  }
}
