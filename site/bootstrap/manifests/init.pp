# Set bootstrap defaults
class bootstrap (
  String $agent_service = 'puppet',
  Stdlib::UnixPath $agent_bin = '/opt/puppetlabs/bin/puppet',
  String $server_service = 'puppetserver',
) {}
