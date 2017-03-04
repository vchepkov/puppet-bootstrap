# class to configure eyaml environment
class bootstrap::eyaml {

  ensure_packages(['gcc'])

  package { 'gpgme':
    provider => 'puppet_gem',
    require  => Package['gcc'],
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
