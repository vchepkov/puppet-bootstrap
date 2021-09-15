# Configure r10k
class bootstrap::r10k_config (
  String  $control_repo = 'https://github.com/vchepkov/puppet-bootstrap.git',
  String  $user         = 'root',
  Boolean $enable       = true,
) {
  file { '/opt/puppetlabs/puppet/bin/refresh-environments.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp("${module_name}/refresh-environments.sh.epp"),
  }

  ensure_packages(['curl','git-core','mailx'])

  class { 'r10k':
    remote   => $control_repo,
    version  => '>= 3.2.0',
    postrun  => ['/opt/puppetlabs/puppet/bin/refresh-environments.sh','$modifiedenvs'],
    cachedir => "${facts['puppet_vardir']}/r10k",
  }

  $ensure = $enable ? {
    true  => 'present',
    false => 'absent',
  }

  cron { 'r10k deploy':
    ensure  => $ensure,
    command => '/opt/puppetlabs/puppet/bin/r10k deploy environment -p >/dev/null',
    user    => $user,
    special => 'daily',
  }
}
