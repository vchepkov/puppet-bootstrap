# bootstrap mco client
class bootstrap::mco {

  # matches policy in hiera
  $user = 'vagrant'

  exec { 'request mco certificate':
    command => '/opt/puppetlabs/puppet/bin/mco choria request_cert',
    creates => "/home/${user}/.puppetlabs/etc/puppet/ssl/certs/${user}.mcollective.pem",
    user    => $user,
    require => Class['mcollective'],
  }
}
