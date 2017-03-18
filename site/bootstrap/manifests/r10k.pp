# Configure r10k
class bootstrap::r10k (
  String  $control_repo  = 'https://github.com/vchepkov/puppet-bootstrap.git',
  String  $user          = 'root',
  Boolean $enable        = true,
) {

  class { '::r10k':
    remote   => $control_repo,
    cachedir => "${facts['puppet_vardir']}/r10k",
  }

  ensure_packages(['mailx'])

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
