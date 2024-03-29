# Configure puppet server
class bootstrap::server (
  String $puppet_server                  = 'puppet.localdomain',
  Optional[Array[String]] $dns_alt_names = undef,
  Boolean $autosign                      = true,
  Optional[String] $environment          = undef,
) inherits bootstrap {
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

  #FIXME: Workaround for puppetdb 6.14
  file { '/etc/puppetlabs/puppetdb/conf.d/auth.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/puppetdb-auth-conf.epp"),
    require => Package[$puppetdb::server::puppetdb_package],
    notify  => Service[$puppetdb::server::puppetdb_service],
  }

  class { 'puppet::server::puppetdb':
    server => $puppet_server,
  }

  class { 'puppet':
    autosign            => $autosign,
    dns_alt_names       => $dns_alt_names,
    environment         => $environment,
    hiera_config        => "${settings::confdir}/hiera.yaml",
    runmode             => 'unmanaged',
    server              => true,
    server_foreman      => false,
    server_reports      => 'puppetdb',
    server_storeconfigs => true,
    puppetmaster        => $puppet_server,
  }

  # workaround for choria expecting puppet in PATH
  file { '/usr/bin/puppet':
    ensure  => 'link',
    target  => '/opt/puppetlabs/bin/puppet',
    seltype => 'puppetagent_exec_t',
  }
}
