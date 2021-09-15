# Puppet maintenance
class bootstrap::maintenance (
  Array[String] $clean_dir = [],
  String $max_age          = '30d',
) {
  systemd::tmpfile { 'puppet-maintenance.conf':
    content => epp("${module_name}/puppet-maintenance.epp", {
        clean_dir => $clean_dir,
        max_age   => $max_age,
    }),
  }
}
