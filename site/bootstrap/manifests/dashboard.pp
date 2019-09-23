# class to install puppet dashboard
class bootstrap::dashboard (
  Optional[String] $version = 'v1.1.0', # https://github.com/voxpupuli/puppetboard
) {

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

  if fact('os.selinux.enabled') {
    apache::custom_config { 'wsgi disable python bytecode':
      filename => 'wsgi-custom.conf',
      source   => "puppet:///modules/${module_name}/wsgi.conf",
    }
  }

  class { 'puppetboard':
    basedir           => '/opt/puppetboard',
    enable_catalog    => true,
    manage_virtualenv => true,
    revision          => $version,
    reports_count     => 20,
    extra_settings    => {
      'DAILY_REPORTS_CHART_DAYS' => '10',
    },
  }

  class { 'puppetboard::apache::conf':
    basedir => '/opt/puppetboard',
  }

}
