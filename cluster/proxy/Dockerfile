FROM httpd:2.4

RUN apt-get update && \
	apt-get install -y \
		libapache2-mod-proxy-html \
		libxml2-dev 
	#a2enmod proxy && \
	#a2enmod proxy_http && \
	#a2enmod proxy_wstunnel


COPY ./proxy.conf /usr/local/apache2/conf/httpd.conf

