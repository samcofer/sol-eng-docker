FROM httpd:2.4

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y \
		libapache2-mod-auth-kerb \
		libxml2-dev \
		libkrb5-dev \
		krb5-user
	#a2enmod proxy && \
	#a2enmod proxy_http && \
	#a2enmod proxy_wstunnel


RUN cp /usr/lib/apache2/modules/mod_auth_kerb.so modules/mod_auth_kerb.so

COPY krb5.conf /etc/krb5.conf

COPY ./proxy-kerb.conf /usr/local/apache2/conf/httpd.conf
COPY ./proxy-kerb/cgi_krb.sh /usr/local/apache2/cgi-bin/krb.sh
COPY ./proxy-kerb/index.html /usr/local/apache2/htdocs/index.html

# make directories
RUN chmod -R 644 /etc/krb* && \
	mkdir -p /etc/krb5.conf.d

# create users
COPY users /tmp/users
RUN awk ' { system("useradd -m -s /bin/bash -p tmp "$1) } ' /tmp/users && \
        awk ' { system("echo "$1":"$2" | chpasswd -m ") } ' /tmp/users && \
        rm /tmp/users

COPY proxy-kerb/docker-entrypoint.sh /docker-entrypoint.sh

# when container is starting
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd-foreground"]

ENV KRB5_TRACE=/tmp/krbtrace.log
