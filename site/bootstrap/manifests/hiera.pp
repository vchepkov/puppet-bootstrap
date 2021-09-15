# class to configure hiera
class bootstrap::hiera inherits bootstrap {
  $build_packages = ['bzip2','gcc','make']
  ensure_packages($build_packages)

  $hiera_server_gems = ['hiera-eyaml']
  $hiera_agent_gems  = ['hiera-eyaml']

  $hiera_agent_gems.each | $gem | {
    package { "${gem} ruby":
      ensure   => installed,
      name     => $gem,
      provider => 'puppet_gem',
      require  => Package[$build_packages],
    }
  }

  $hiera_server_gems.each | $gem | {
    package { "${gem} jruby":
      ensure   => installed,
      name     => $gem,
      provider => 'puppetserver_gem',
      require  => Package[$build_packages],
    }

    Service <| title == $bootstrap::server_service |> {
      subscribe +> Package["${gem} jruby"],
    }
  }

  file { $settings::hiera_config:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/hiera5.yaml.epp"),
  }

  Service <| title == $bootstrap::server_service |> {
    subscribe +> File[$settings::hiera_config],
  }

  file { '/root/.eyaml':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { '/root/.eyaml/config.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/eyaml.config.epp"),
  }

  file { '/opt/puppetlabs/bin/eyaml':
    ensure => link,
    target => '/opt/puppetlabs/puppet/bin/eyaml',
  }
}
