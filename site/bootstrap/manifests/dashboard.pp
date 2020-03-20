# class to install puppet dashboard
class bootstrap::dashboard (
  Optional[String] $version = 'v1.0.0', # https://github.com/voxpupuli/puppetboard
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
    notify            => Class['apache::service'],
  }

  # FIXME: Workaround for broken pypuppetdb v1.1.0
  # Can't use file_line because of the dependency cycle
  exec { 'fix pypuppetdb version':
    command => '/bin/sed -i "s/pypuppetdb.*/pypuppetdb ==1.0.0/" /opt/puppetboard/puppetboard/requirements.txt',
    unless  => '/bin/grep "pypuppetdb ==1.0.0" /opt/puppetboard/puppetboard/requirements.txt',
    require => Vcsrepo['/opt/puppetboard/puppetboard'],
    before  => Python::Virtualenv['/opt/puppetboard/virtenv-puppetboard'],
  }

  class { 'puppetboard::apache::conf':
    basedir   => '/opt/puppetboard',
    subscribe => Class['puppetboard'],
  }

}
