#!/bin/bash
DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply --modulepath /etc/puppetlabs/code/environments/production/modules ${DIR}/bootstrap.pp
/opt/puppetlabs/bin/puppet agent -t
exit 0
