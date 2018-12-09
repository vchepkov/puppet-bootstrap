!#/bin/bash

for environment in $1; do
  /opt/puppetlabs/bin/puppet generate types --environment $environment
done
