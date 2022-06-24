#!/bin/bash
# expects to be executed as the postgres user

# set-up kerb stuff
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "ktadd -k /var/lib/postgresql/data/krb5.keytab postgres/k-postgres@DOCKER-RSTUDIO.COM"
kadmin -p ubuntu/admin -w ubuntu -q "addprinc -randkey host/k-postgres@DOCKER-RSTUDIO.COM"

sed -i "s@#krb_server_keyfile = ''@krb_server_keyfile = '/var/lib/postgresql/data/krb5.keytab'@" /var/lib/postgresql/data/postgresql.conf
kinit -k -t /var/lib/postgresql/data/krb5.keytab  postgres/k-postgres

# configure database
psql -c 'CREATE ROLE "postgres/k-postgres@DOCKER-RSTUDIO.COM" SUPERUSER LOGIN'


echo "krb_domain      /^(.*)@DOCKER-RSTUDIO\.COM$     \1" >>  ${PGDATA}/pg_ident.conf

# seed users in the database
# - presumes that /tmp/users is still around
awk ' { system("psql -c '\''CREATE ROLE \""$1"\" WITH LOGIN;'\''") } ' /tmp/users

# reload database params
/usr/lib/postgresql/${PG_MAJOR}/bin/pg_ctl reload
