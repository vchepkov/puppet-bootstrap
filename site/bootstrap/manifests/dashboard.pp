# install puppet dashboard
class bootstrap::dashboard {
  class { 'apache':
    server_tokens    => 'Prod',
    server_signature => 'Off',
    trace_enable     => 'Off',
    mpm_module       => 'event',
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    owner   => root,
    group   => root,
    content => '<html><head><meta http-equiv="refresh" content="0;/puppetboard"></head></html>',
    require => Class['apache'],
  }

  include puppetboard::install
  $ssldir = "${puppetboard::install::basedir}/local/ssl"

  puppetboard { 'local':
    host                => $trusted['certname'],
    port                => 8081,
    default_environment => '*',
    config              => {
      'DAILY_REPORTS_CHART_DAYS' => '10',
      'DAILY_REPORTS_CHART_MODE' => "'split'",
      'ENABLE_CATALOG'           => 'True',
      'ENABLE_CLASS'             => 'True',
      'PUPPETDB_CERT'            => "'${ssldir}/cert.pem'",
      'PUPPETDB_KEY'             => "'${ssldir}/key.pem'",
      'PUPPETDB_SSL_VERIFY'      => "'${ssldir}/ca.pem'",
    },
  }

  # The agent's private key is root-only; puppetboard needs its own copy.
  file { $ssldir:
    ensure  => directory,
    owner   => 'puppetboard',
    group   => 'puppetboard',
    mode    => '0750',
    require => Puppetboard['local'],
  }

  $ssl_files = {
    'cert.pem' => "${settings::certdir}/${trusted['certname']}.pem",
    'key.pem'  => "${settings::privatekeydir}/${trusted['certname']}.pem",
    'ca.pem'   => $settings::localcacert,
  }

  $ssl_files.each |$name, $source| {
    file { "${ssldir}/${name}":
      ensure    => file,
      owner     => 'puppetboard',
      group     => 'puppetboard',
      mode      => '0400',
      source    => $source,
      show_diff => false,
    }
  }

  puppetboard::apache { 'local':
    url_path => '/puppetboard',
  }
}
