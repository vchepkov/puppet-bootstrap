# Puppet maintenance
class bootstrap::maintenance (
  Array[Stdlib::Unixpath] $clean_dir = [],
  String $max_age = '30d',
  Optional[String] $user = undef,
) {
  if $user {
    $clean_dir.each | $dir | {
      exec { "install -d -o ${user} ${dir}":
        unless => "test \"\$(stat --printf '%U' ${dir})\" = \"${user}\"",
        path   => $facts['path'],
        before => Systemd::Tmpfile['puppet-maintenance.conf'],
      }
    }
  }

  systemd::tmpfile { 'puppet-maintenance.conf':
    content => epp("${module_name}/puppet-maintenance.epp", {
        clean_dir => $clean_dir,
        max_age   => $max_age,
    }),
  }
}
