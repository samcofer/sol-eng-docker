#!/bin/bash
set -ex

# there has to be a better way
# have to wait for the KDC to come up
sleep 10

# add kerb configuration
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/apache-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/apache-kerb"

exec "$@"

