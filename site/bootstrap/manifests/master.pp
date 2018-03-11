# Configure puppet master
class bootstrap::master (
  String $puppet_master         = 'master.localdomain',
  Boolean $autosign             = false,
  Optional[String] $environment = undef,
) {

  class { 'puppetdb::database::postgresql':
    manage_package_repo => true,
    postgres_version    => '9.6',
    before              => Class['puppetdb::server'],
  }

  class { 'puppetdb::server':
    listen_address         => '0.0.0.0',
    listen_port            => '8080',
    manage_firewall        => false,
    node_ttl               => '0s',
    node_purge_ttl         => '0s',
  }

  class { 'puppet':
    puppetmaster                  => $puppet_master,
    server                        => true,
    environment                   => $environment,
    autosign                      => $autosign,
    server_foreman                => false,
    server_puppetdb_host          => $puppet_master,
    server_reports                => 'puppetdb',
    server_storeconfigs_backend   => 'puppetdb',
    server_external_nodes         => '',
    server_environments           => [],
    server_common_modules_path    => [],
    hiera_config                  => "${::settings::confdir}/hiera.yaml",
    show_diff                     => true,
    additional_settings           => {
      'strict' => 'off',
      'color'  => 'false',
    },
  }

# Don't start agent until master is configured
  Service['puppetserver'] -> Service['puppet']

  file { '/etc/systemd/system/puppet.service.d':
    ensure => directory,
  }

  file { '/etc/systemd/system/puppet.service.d/local.conf':
    ensure => file,
    source => "puppet:///modules/${module_name}/puppet-systemd.conf",
  }

}
