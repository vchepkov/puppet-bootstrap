#!/bin/bash
DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply \
${DIR}/bootstrap.pp $*
