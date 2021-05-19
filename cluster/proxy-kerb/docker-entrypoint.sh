#!/bin/bash
set -ex

# there has to be a better way
# have to wait for the KDC to come up
sleep 10

# add kerb configuration
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey HTTP/proxy-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab HTTP/proxy-kerb"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey HTTP/proxy-kerb@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab HTTP/proxy-kerb@DOCKER-RSTUDIO.COM"

# fix permissions
chmod +r /etc/krb5.keytab

exec "$@"
