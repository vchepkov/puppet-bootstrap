#!/bin/bash
DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply \
--modulepath /etc/puppetlabs/code/environments/puppet5/modules:/etc/puppetlabs/code/environments/puppet5/site \
${DIR}/bootstrap.pp $*
