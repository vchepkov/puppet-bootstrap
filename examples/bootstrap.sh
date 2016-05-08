#!/bin/bash
DIR=$(dirname $0)
# To resolve dependency circle install puppet server first, then reconfigure it to use puppetdb
env FACTER_bootstrap=yes /opt/puppetlabs/bin/puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules ${DIR}/bootstrap.pp
/opt/puppetlabs/bin/puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules ${DIR}/bootstrap.pp
