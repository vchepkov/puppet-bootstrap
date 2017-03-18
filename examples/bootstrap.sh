#!/bin/bash
DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply \
--modulepath /etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/environments/production/site \
${DIR}/bootstrap.pp $*
