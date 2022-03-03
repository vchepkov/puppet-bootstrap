# Configure MCO access
class bootstrap::mco (
  Array[String] $admins = [],
) {
  $admins.each | $user | {
    exec { "request mco certificate for ${user}":
      command     => '/usr/bin/choria enroll',
      cwd         => '/',
      creates     => "/home/${user}/.puppetlabs/etc/puppet/ssl/certs/${user}.mcollective.pem",
      user        => $user,
      environment => ["HOME=/home/${user}", "USER=${user}"],
      require     => Class['mcollective_choria'],
    }
  }
}
