#!/bin/bash
set -ex

# there has to be a better way
# have to wait for the KDC to come up
sleep 10

# add kerb configuration
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/apache-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/apache-kerb"

kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey apache-kerb/apache-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab apache-kerb/apache-kerb"

kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey HTTP/apache-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab HTTP/apache-kerb"

# fix permissions
chmod +r /etc/krb5.keytab

exec "$@"
