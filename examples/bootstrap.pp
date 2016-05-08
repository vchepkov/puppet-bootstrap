class { 'r10k':
  remote   => 'https://github.com/vchepkov/puppet-bootstrap.git',
  cachedir => '/var/cache/r10k',
}

class { 'puppet':
  server                        => true,
  server_implementation         => 'puppetserver',
  server_foreman                => false,
  server_reports                => 'store',
  server_external_nodes         => '',
  server_directory_environments => true,
  server_environments           => ['production'],
  server_common_modules_path    => ['/opt/puppetlabs/puppet/modules'],
  server_jvm_min_heap_size      => '512m',
  server_jvm_max_heap_size      => '512m',
  server_jvm_extra_args         => '-XX:MaxPermSize=256m',
  server_strict_variables       => true,
}

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
  hiera_yaml         => "${::settings::codedir}/hiera.yaml",
  keysdir            => "${::settings::codedir}/keys",
  merge_behavior     => 'deeper',
  eyaml              => true,
  create_keys        => true,
}
