# Configure puppet server
class bootstrap::server (
  String $puppet_server                  = 'puppet.localdomain',
  Optional[Array[String]] $dns_alt_names = undef,
  Boolean $autosign                      = true,
  Optional[String] $environment          = undef,
  String $postgres_version               = '17',
) inherits bootstrap {
  # dnfmodule was deprecated in EL10
  if versioncmp ($facts['os']['release']['major'], '10') < 0 {
    package { 'postgresql-module':
      ensure   => disabled,
      name     => 'postgresql',
      provider => 'dnfmodule',
      before   => Class['openvoxdb'],
    }
  }

  # puppetlabs/postgresql ships only the x86_64 PGDG key
  if $facts['os']['architecture'] == 'aarch64' {
    Yumrepo <| title == 'yum.postgresql.org' or title == 'pgdg-common' |> {
      gpgkey => 'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-AARCH64-RHEL',
    }
  }

  class { 'openvoxdb':
    manage_firewall         => false,
    listen_port             => 8080,
    disable_update_checking => true,
    postgres_version        => $postgres_version,
  }

  # Replaces puppet::server::puppetdb, which hardcodes puppetlabs/puppetdb classes.
  class { 'openvoxdb::master::config':
    puppetdb_server     => $puppet_server,
    manage_storeconfigs => false,
    restart_puppet      => false,
  }
  Class['openvoxdb::master::puppetdb_conf'] ~> Class['puppet::server::service']

  class { 'puppet':
    autosign              => $autosign,
    dns_alt_names         => $dns_alt_names,
    environment           => $environment,
    hiera_config          => "${settings::confdir}/hiera.yaml",
    runmode               => 'unmanaged',
    server                => true,
    server_foreman        => false,
    server_reports        => 'puppetdb',
    server_storeconfigs   => true,
    agent_server_hostname => $puppet_server,
  }

  # workaround for choria expecting puppet in PATH
  file { '/usr/bin/puppet':
    ensure => 'link',
    target => '/opt/puppetlabs/bin/puppet',
  }
}
