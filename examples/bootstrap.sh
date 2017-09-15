#!/bin/bash
DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply \
--modulepath /etc/puppetlabs/code/environments/choria/modules:/etc/puppetlabs/code/environments/choria/site \
${DIR}/bootstrap.pp $*
