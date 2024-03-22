# Configure r10k
class bootstrap::r10k_config (
  String  $control_repo  = 'https://github.com/vchepkov/puppet-bootstrap.git',
  String  $user          = 'root',
  Boolean $enable_deploy = true,
) {
  file { '/opt/puppetlabs/puppet/bin/refresh-environments.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp("${module_name}/refresh-environments.sh.epp"),
  }

  stdlib::ensure_packages(['curl','git-core'])

  class { 'r10k':
    remote   => $control_repo,
    version  => '>= 3.9.0',
    postrun  => ['/opt/puppetlabs/puppet/bin/refresh-environments.sh','$modifiedenvs'],
    cachedir => "${facts['puppet_vardir']}/r10k",
  }

  $ensure = $enable_deploy ? {
    true  => 'present',
    false => 'absent',
  }

  systemd::timer_wrapper { 'r10k_deploy':
    ensure      => $ensure,
    command     => '/opt/puppetlabs/puppet/bin/r10k deploy environment -m -v error',
    on_calendar => 'daily',
    user        => $user,
  }
}
