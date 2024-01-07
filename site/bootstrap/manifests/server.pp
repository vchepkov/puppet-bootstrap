# Configure puppet server
class bootstrap::server (
  String $puppet_server                  = 'puppet.localdomain',
  Optional[Array[String]] $dns_alt_names = undef,
  Boolean $autosign                      = true,
  Optional[String] $environment          = undef,
  String $postgres_version               = '14',
) inherits bootstrap {
  package { 'postgresql-module':
    ensure   => disabled,
    name     => 'postgresql',
    provider => 'dnfmodule',
  }
  #FIXME: https://github.com/puppetlabs/puppetlabs-postgresql/issues/1565
  -> yumrepo { 'yum.postgresql.org':
    descr    => "PostgreSQL ${postgres_version} \$releasever - \$basearch",
    baseurl  => "https://download.postgresql.org/pub/repos/yum/${postgres_version}/redhat/rhel-\$releasever-\$basearch",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL',
  }
  -> class { 'puppetdb::database::postgresql':
    manage_package_repo => false,
    postgres_version    => $postgres_version,
    before              => Class['puppetdb::server'],
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
    ensure  => 'link',
    target  => '/opt/puppetlabs/bin/puppet',
    seltype => 'puppetagent_exec_t',
  }
}
