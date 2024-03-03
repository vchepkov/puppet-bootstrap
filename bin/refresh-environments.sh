#!/bin/bash

/bin/curl -k --cert $(puppet config print hostcert) \
  --key $(puppet config print hostprivkey) -X DELETE \
  https://localhost:8140/puppet-admin-api/v1/environment-cache
