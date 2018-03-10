#!/bin/bash

puppet_environment=${PUPPET_ENV:-production}

/opt/puppetlabs/puppet/bin/r10k deploy environment $puppet_environment -vp || exit 1

/opt/puppetlabs/bin/puppet apply \
--environment $puppet_environment \
-e "class { 'bootstrap::master': environment => $puppet_environment }"
