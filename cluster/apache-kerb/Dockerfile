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


# create users
COPY users /tmp/users
#RUN awk ' {system("if [ ! -f /usr/local/apache2/passwords ]; then htpasswd -b -c /usr/local/apache2/passwords "$1" "$2"; else htpasswd -b /usr/local/apache2/passwords "$1" "$2"; fi;") } ' /tmp/users && \
        #rm /tmp/users

RUN cp /usr/lib/apache2/modules/mod_auth_kerb.so modules/mod_auth_kerb.so

COPY ./apache-kerb.conf /usr/local/apache2/conf/httpd.conf
