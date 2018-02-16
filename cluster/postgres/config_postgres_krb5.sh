
# set-up kerb stuff
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/k-postgres@DOCKER-RSTUDIO.COM"

kinit -k -t /etc/krb5.keytab  postgres/k-postgres
chown postgres:postgres /etc/krb5.keytab

# configure database
su postgres -c "psql -c 'CREATE ROLE \"postgres/k-postgres@DOCKER-RSTUDIO.COM\" SUPERUSER LOGIN'"

#echo "krb_server_keyfile = '/etc/krb5.keytab'" >> /var/lib/postgresql/data/postgresql.conf
#echo "host all all 0.0.0.0/0 gss include_realm=1 krb_realm=DOCKER-RSTUDIO.COM" >> /var/lib/postgresql/data/pg_hba.conf

chown postgres:postgres /tmp/pg_hba.conf 
chown postgres:postgres /tmp/postgresql.conf

cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
cp /tmp/postgresql.conf /var/lib/postgresql/data/postgresql.conf

# seed users in the database
# - presumes that /tmp/users is still around
#RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users
#awk ' { system("psql -h localhost -d postgres -c '
#awk ' { system("psql -h localhost -d postgres -p 49159 -c \" SELECT '\''test'\'' \"")}' ~/users 

# reload database params
su postgres -c "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_ctl reload"


