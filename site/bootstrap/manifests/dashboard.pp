# class to install puppet dashboard
class bootstrap::dashboard {

  class { 'apache':
    server_tokens    => 'Prod',
    server_signature => 'Off',
    trace_enable     => 'Off',
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    owner   => root,
    group   => root,
    content => '<html><head><meta http-equiv="refresh" content="0;/puppetboard"></head></html>',
    require => Class['apache'],
  }

  include apache::mod::wsgi

  class { 'puppetboard':
    basedir           => '/opt/puppetboard',
    enable_catalog    => true,
    manage_virtualenv => true,
    revision          => 'v0.3.0', # https://github.com/voxpupuli/puppetboard
    reports_count     => 20,
  }

  class { 'puppetboard::apache::conf':
    basedir => '/opt/puppetboard',
  }

}
