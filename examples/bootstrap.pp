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

class { 'puppet':
  server                        => true,
  server_foreman                => false,
  server_puppetdb_host          => 'master.localdomain',
  server_reports                => 'puppetdb',
  server_storeconfigs_backend   => 'puppetdb',
  server_external_nodes         => '',
  server_environments           => ['production'],
  server_common_modules_path    => [],
  server_jvm_min_heap_size      => '512m',
  server_jvm_max_heap_size      => '512m',
  server_strict_variables       => true,
  hiera_config                  => "${::settings::confdir}/hiera.yaml",
  show_diff                     => true,
}

# Don't start agent until master is configured
Service['puppetserver'] -> Service['puppet']

class { 'hiera':
  hierarchy          => [
    'nodes/%{clientcert}',
    'roles/%{role}',
    'locations/%{location}',
    'tiers/%{tier}',
    'common/global',
  ],
  master_service     => 'puppetserver',
  provider           => 'puppetserver_gem',
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
  revision          => 'v0.1.2',
  reports_count     => 20,
  require           => Class['python'],
}

class { 'puppetboard::apache::conf':
  basedir => '/opt/puppetboard',
}
