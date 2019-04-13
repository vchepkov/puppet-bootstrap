!#/bin/bash

CERT=$(puppet config print hostcert)
KEY=$(puppet config print hostprivkey)

for environment in $1; do
  /opt/puppetlabs/bin/puppet generate types --environment $environment
  /bin/curl -k --cert $CERT --key $KEY -X DELETE \
    https://localhost:8140/puppet-admin-api/v1/environment-cache\?environment=$environment
done
