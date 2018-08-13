FROM httpd:2.4

RUN apt-get update && \
	apt-get install -y \
		libapache2-mod-proxy-html \
		libxml2-dev 
	#a2enmod proxy && \
	#a2enmod proxy_http && \
	#a2enmod proxy_wstunnel


# create users
COPY users /tmp/users
RUN awk ' {system("if [ ! -f /usr/local/apache2/passwords ]; then htpasswd -b -c /usr/local/apache2/passwords "$1" "$2"; else htpasswd -b /usr/local/apache2/passwords "$1" "$2"; fi;") } ' /tmp/users && \
        rm /tmp/users

COPY ./apache-proxy-auth.conf /usr/local/apache2/conf/httpd.conf
