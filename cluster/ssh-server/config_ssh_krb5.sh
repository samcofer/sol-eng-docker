kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/k-ssh-server"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab host/k-ssh-server"
