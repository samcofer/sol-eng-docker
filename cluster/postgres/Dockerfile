FROM postgres:9.6

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y \
	apt-transport-https \
	wget && \
	apt-get dist-upgrade -y

# kerberos client
RUN apt-get install -y \
	krb5-user \
	ntp

COPY krb5.conf /etc/krb5.conf

RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d

# create users
COPY users /tmp/users
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users 
# - leave it around to create database users, too

# remove previous postgres install
RUN apt-get remove -y postgresql-$PG_MAJOR postgresql-client-$PG_MAJOR && apt-get autoremove -y

ENV PG_MAJOR=10.1
ENV PG_VERSION=10.1.0
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/postgresql/${PG_MAJOR}/bin
# build postgres from source
RUN apt-get install -y \
	gcc \
	make \
	libreadline-dev \
	zlib1g-dev \
	libgss-dev \
	libkrb5-dev && \
	wget https://ftp.postgresql.org/pub/source/v${PG_MAJOR}/postgresql-${PG_MAJOR}.tar.gz && \
	gunzip postgresql-${PG_MAJOR}.tar.gz && \
	tar xf postgresql-${PG_MAJOR}.tar && \
	cd postgresql-${PG_MAJOR} && \
	./configure \
	  --with-gssapi \
	  --prefix=/usr/lib/postgresql/${PG_MAJOR} \
	  && \
	make && \
	make install
	
# provision with config files
COPY postgres/pg_hba.conf /tmp/pg_hba.conf
COPY postgres/postgresql.conf /tmp/postgresql.conf
COPY postgres/pg_ident.conf /tmp/pg_ident.conf

# provision with configuration script
COPY postgres/config_postgres_krb5.sh /docker-entrypoint-initdb.d/config_postgres_krb5.sh
RUN chmod +x /docker-entrypoint-initdb.d/config_postgres_krb5.sh && \
  chmod 777 /var/log && \
  chmod 777 /etc && \
  # b/c chown flag not currently supported on COPY
  chown postgres:postgres /tmp/pg_hba.conf && \
  chown postgres:postgres /tmp/postgresql.conf && \
  chown postgres:postgres /tmp/pg_ident.conf


# RUN su postgres -c "psql  -c 'CREATE ROLE \"postgres/docker-rstudio.com@DOCKER-RSTUDIO.COM\" SUPERUSER LOGIN'"

# when container is starting
# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
