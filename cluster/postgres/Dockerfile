FROM postgres

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
RUN awk ' { pass=system("openssl passwd -1 "$2); system("useradd -m -p "pass" -s /bin/bash "$1) } ' /tmp/users && \
        rm /tmp/users

# build postgres from source
RUN apt-get install -y \
	gcc \
	make \
	libreadline-dev \
	zlib1g-dev \
	libgss-dev \
	libkrb5-dev && \
	wget https://ftp.postgresql.org/pub/source/v10.1/postgresql-10.1.tar.gz && \
	gunzip postgresql-10.1.tar.gz && \
	tar xf postgresql-10.1.tar && \
	cd postgresql-10.1 && \
	./configure --with-gssapi && \
	make && \
	make install
	
# provision with configuration script
COPY postgres/config_postgres_krb5.sh /usr/local/bin/config_postgres_krb5.sh

# RUN su postgres -c "psql  -c 'CREATE ROLE \"postgres/docker-rstudio.com@DOCKER-RSTUDIO.COM\" SUPERUSER LOGIN'"

# when container is starting
# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
