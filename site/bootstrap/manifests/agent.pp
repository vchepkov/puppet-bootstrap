# Configure puppet agent
class bootstrap::agent inherits bootstrap {
  include chrony

  systemd::unit_file { 'puppet-onetime.service':
    enable  => true,
    content => epp("${module_name}/puppet-onetime.epp"),
  }

  include bootstrap::maintenance
}
