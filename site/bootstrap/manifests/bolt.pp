# Configure OpenBolt with the choria transport for MCO admins
class bootstrap::bolt (
  String $package = 'openbolt',
  String $environment = 'production',
) {
  require bootstrap::mco

  package { 'openbolt':
    ensure => installed,
    name   => $package,
  }

  $inventory = {
    'config'  => {
      'transport' => 'choria',
      'choria'    => { 'puppet-environment' => $environment },
    },
    'targets' => [{ '_plugin' => 'puppetdb', 'query' => 'nodes[certname] {}' }],
  }

  $bootstrap::mco::admins.each | $user | {
    $home = "/home/${user}"

    # bolt_tasks agents download task files from the server, so read the same modules
    $project = {
      'log'        => { 'bolt-debug.log' => 'disable' },
      'modulepath' => [
        "${settings::environmentpath}/${environment}/modules",
        "${settings::environmentpath}/${environment}/site",
        '/etc/puppetlabs/code/modules',
        '/opt/puppetlabs/puppet/modules',
      ],
      'puppetdb'   => {
        'server_urls' => ['http://localhost:8080'],
        'cacert'      => "${home}/.puppetlabs/etc/puppet/ssl/certs/ca.pem",
      },
    }

    file { ["${home}/.puppetlabs", "${home}/.puppetlabs/bolt"]:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0755',
    }

    file { "${home}/.puppetlabs/bolt/bolt-project.yaml":
      ensure  => file,
      owner   => $user,
      group   => $user,
      mode    => '0644',
      content => stdlib::to_yaml($project),
    }

    file { "${home}/.puppetlabs/bolt/inventory.yaml":
      ensure  => file,
      owner   => $user,
      group   => $user,
      mode    => '0644',
      content => stdlib::to_yaml($inventory),
    }
  }
}
