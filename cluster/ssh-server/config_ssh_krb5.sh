kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/kerberos-ssh-server"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/kerberos-ssh-server"
