$puppet_master = 'master.localdomain'

class { 'r10k':
  remote   => 'https://github.com/vchepkov/puppet-bootstrap.git',
}

class { 'puppetdb::database::postgresql':
  manage_package_repo => true,
  postgres_version    => '9.4',
  before              => Class['puppetdb::server'],
}

package { 'postgresql94-contrib':
  require => Class['puppetdb::database::postgresql'],
  before  => Class['puppetdb::server'],
}

class { 'puppetdb::server':
  listen_address         => '0.0.0.0',
  listen_port            => '8080',
  manage_firewall        => false,
# database_max_pool_size => 8,
}

postgresql::server::extension { 'pg_trgm':
  database => 'puppetdb',
  require  => Package['postgresql94-contrib'],
  before   => Service['puppetdb'];
}

class { 'puppet':
  puppetmaster                  => $puppet_master,
  server                        => true,
  autosign                      => true,
  server_foreman                => false,
  server_puppetdb_host          => $puppet_master,
  server_reports                => 'puppetdb',
  server_storeconfigs_backend   => 'puppetdb',
  server_external_nodes         => '',
  server_environments           => [],
  server_common_modules_path    => [],
  server_jvm_min_heap_size      => '512m',
  server_jvm_max_heap_size      => '512m',
  hiera_config                  => "${::settings::confdir}/hiera.yaml",
  show_diff                     => true,
  additional_settings           => {
    'strict' => 'off',
                                   },
}

# Need to populate ssl directory for PuppetDB
exec { 'puppetdb ssl-setup':
  command => '/opt/puppetlabs/server/bin/puppetdb ssl-setup',
  creates => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
  require => [Package['puppetdb'],Class['puppet::server::config']],
  before  => Service['puppetdb'],
}

# Don't start agent until master is configured
Service['puppetserver'] -> Service['puppet']

# Workaround for geppetto
$hiera_gem_provider = 'puppetserver_gem'

class { 'hiera':
  hierarchy          => [
    'nodes/%{clientcert}',
    'roles/%{role}',
    'locations/%{location}',
    'groups/%{group}',
    'tiers/%{tier}',
    'common/global',
  ],
  master_service     => 'puppetserver',
  provider           => $hiera_gem_provider,
  manage_package     => true,
  puppet_conf_manage => false,
  hiera_yaml         => "${::settings::confdir}/hiera.yaml",
  keysdir            => "${::settings::codedir}/keys",
  merge_behavior     => 'deeper',
  eyaml              => true,
  eyaml_gpg          => true,
  create_keys        => true,
  create_symlink     => false,
}
