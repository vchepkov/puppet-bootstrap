# Configure MCO admin
# TODO: convert into define
class bootstrap::mco_vagrant {

  # matches policy in hiera
  $user = 'vagrant'

  exec { 'request mco certificate':
    command     => '/opt/puppetlabs/puppet/bin/mco choria request_cert',
    creates     => "/home/${user}/.puppetlabs/etc/puppet/ssl/certs/${user}.mcollective.pem",
    user        => $user,
    environment => ["HOME=/home/${user}", "USER=${user}"],
    require     => Class['mcollective_choria'],
  }
}
