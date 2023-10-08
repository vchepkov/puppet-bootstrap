# Puppet maintenance
class bootstrap::maintenance (
  Array[Stdlib::Unixpath] $clean_dir = [],
  String $user = 'puppet',
  String $max_age = '30d',
) {
  # systemd refuses clean directories if they are owned by root
  $clean_dir.each | $dir | {
    exec { "chown ${user} ${dir}":
      unless => "test \"\$(stat --printf '%U' ${dir})\" = \"${user}\"",
      path   => $facts['path'],
      notify => Systemd::Tmpfile['puppet-maintenance.conf'],
    }
  }
  systemd::tmpfile { 'puppet-maintenance.conf':
    content => epp("${module_name}/puppet-maintenance.epp", {
        clean_dir => $clean_dir,
        max_age   => $max_age,
    }),
  }
}
