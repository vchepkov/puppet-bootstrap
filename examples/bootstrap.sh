#!/bin/bash

puppet_environment=${PUPPET_ENV:-production}

/opt/puppetlabs/puppet/bin/r10k deploy environment $puppet_environment -vp || exit 1

# Workaround for bug https://tickets.puppetlabs.com/browse/PUP-9602
rm -rf $(/opt/puppetlabs/bin/puppet config print environmentpath)/${puppet_environment}/.resource_types

/opt/puppetlabs/bin/puppet apply \
--environment $puppet_environment \
-e "class { 'bootstrap::master': environment => $puppet_environment }"
