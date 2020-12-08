#!/bin/bash
set -ex
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/kerberos-ssh-server"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/kerberos-ssh-server"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/$(hostname)"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/$(hostname)"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/kerberos-ssh-server.default.svc.cluster.local"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/kerberos-ssh-server.default.svc.cluster.local"
