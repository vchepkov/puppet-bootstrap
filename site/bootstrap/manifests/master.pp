# Configure puppet master
class bootstrap::master (
  String $puppet_master         = 'master.localdomain',
  Boolean $autosign             = false,
  Boolean $jruby9k              = true,
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
  }

  class { 'puppet':
    puppetmaster                  => $puppet_master,
    server                        => true,
    environment                   => $environment,
    autosign                      => $autosign,
    server_check_for_updates      => false,
    server_foreman                => false,
    server_puppetserver_jruby9k   => $jruby9k,
    server_puppetdb_host          => $puppet_master,
    server_reports                => 'puppetdb',
    server_storeconfigs_backend   => 'puppetdb',
    server_external_nodes         => '',
    server_environments           => [],
    server_common_modules_path    => [],
    hiera_config                  => "${::settings::confdir}/hiera.yaml",
    show_diff                     => true,
    additional_settings           => {
      'color'            => 'false',
      'strict'           => 'off',
      'strict_variables' => 'true',
    },
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
    target  => '/opt/puppetlabs/puppet/bin/puppet',
  }
}
