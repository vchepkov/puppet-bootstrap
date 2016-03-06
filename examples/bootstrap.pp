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
}
