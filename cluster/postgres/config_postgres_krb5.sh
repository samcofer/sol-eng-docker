# expects to be executed as the postgres user

# set-up kerb stuff
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /etc/krb5.keytab postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/k-postgres@DOCKER-RSTUDIO.COM"

kinit -k -t /etc/krb5.keytab  postgres/k-postgres
chown postgres:postgres /etc/krb5.keytab

# configure database
psql -c 'CREATE ROLE \"postgres/k-postgres@DOCKER-RSTUDIO.COM\" SUPERUSER LOGIN'

chown postgres:postgres /tmp/pg_hba.conf 
chown postgres:postgres /tmp/postgresql.conf

cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
cp /tmp/postgresql.conf /var/lib/postgresql/data/postgresql.conf

# seed users in the database
# - presumes that /tmp/users is still around
awk ' { system("psql -h localhost -d postgres -p 5432 -c '\''CREATE ROLE \""$1"@DOCKER-RSTUDIO.COM\" WITH LOGIN;'\''") } ' /tmp/users

# reload database params
usr/lib/postgresql/${PG_MAJOR}/bin/pg_ctl reload


