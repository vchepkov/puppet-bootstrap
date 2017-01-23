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
  manage_firewall => false,
}

postgresql::server::extension { 'pg_trgm':
  database => 'puppetdb',
  require  => Package['postgresql94-contrib'],
  before   => Service['puppetdb'];
}

class { 'puppet':
  puppetmaster                  => $puppet_master,
  server                        => true,
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
  keysdir            => "${::settings::confdir}/keys",
  merge_behavior     => 'deeper',
  eyaml              => true,
  create_keys        => true,
}

class { 'apache': }

file { '/var/www/html/index.html':
  ensure  => file,
  owner   => root,
  group   => root,
  content => '<html><head><meta http-equiv="refresh" content="0;/puppetboard"></head></html>',
  require => Class['apache'],
}

class { 'apache::mod::wsgi': }

class { 'python':
  virtualenv => present,
  dev        => present,
}

class { 'puppetboard':
  basedir           => '/opt/puppetboard',
  enable_catalog    => true,
  revision          => 'v0.2.0', # https://github.com/voxpupuli/puppetboard
  reports_count     => 20,
  require           => Class['python'],
}

class { 'puppetboard::apache::conf':
  basedir => '/opt/puppetboard',
}

class { 'mcollective':
  client_password => 'ykMofyxshgeNkojtxz17',
  server_password => 'tnhi2qbyo1HpeXqyngaa',
  psk_key         => '09cicjWvwqdyrizUzcsj',
  hosts           => [ $puppet_master ],
}

include mcollective::middleware

$plugins = ['puppet','package','service','shell']

include mcollective::client
$plugins.each | $plugin | {
  mcollective::plugin::client { $plugin:
    version => 'installed',
    require => Yumrepo['puppetlabs-products'],
  }
}
