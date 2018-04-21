# Configure puppet agent
class bootstrap::agent {
  include ntp
  include git

  # Conflicts with ntpd
  package { 'chrony':
    ensure => 'purged',
    before => Class['ntp'],
  }
}
