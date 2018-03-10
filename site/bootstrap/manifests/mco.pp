# Configure MCO access
class bootstrap::mco (
  Array[String] $admins = [],
){
  $admins.each | $user | {
    exec { 'request mco certificate':
      command     => '/opt/puppetlabs/puppet/bin/mco choria request_cert',
      creates     => "/home/${user}/.puppetlabs/etc/puppet/ssl/certs/${user}.mcollective.pem",
      user        => $user,
      environment => ["HOME=/home/${user}", "USER=${user}"],
      require     => Class['mcollective_choria'],
    }
  }
}
