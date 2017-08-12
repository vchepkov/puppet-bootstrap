# class to configure hiera
class bootstrap::hiera (
  String $server_service = 'puppetserver',
){

  $build_packages = ['bzip2','gcc','libgpg-error-devel']
  ensure_packages($build_packages)

  $hiera_server_gems = ['hiera-eyaml','hiera-eyaml-gpg','ruby_gpg']
  $hiera_agent_gems  = ['hiera-eyaml','hiera-eyaml-gpg','gpgme']

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
    }

    Service <| title == $server_service |> {
      subscribe +> Package["${gem} jruby"],
    }

  }

  file { $::settings::hiera_config:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/hiera5.yaml",
  }

  Service <| title == $server_service |> {
    subscribe +> File[$::settings::hiera_config],
  }

  file { '/root/.eyaml':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '700',
  }

  file { '/root/.eyaml/config.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '600',
    content => template("${module_name}/eyaml.config.erb"),
  }

  file { '/opt/puppetlabs/bin/eyaml':
    ensure  => link,
    target  => '/opt/puppetlabs/puppet/bin/eyaml',
  }

}
