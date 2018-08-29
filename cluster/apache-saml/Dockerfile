FROM httpd:2.4

# install system deps
RUN apt-get update && \
	apt-get install -y \
	pkg-config \
	liblasso3-dev \
	autoconf \
	gcc \
	autotools-dev \
	glib \
	pkgconf \
	libcurl4-gnutls-dev


# build and install mod_auth_mellon
RUN cd /usr/src && \
	wget https://github.com/Uninett/mod_auth_mellon/archive/v0.14.0.tar.gz && \
	tar -xzvf v0.14.0.tar.gz && \
	cd v0.14.0 && \
	aclocal && \
	autoreconf && \
	autoconf && \
	./configure --with-apxs2=/usr/local/apche2/bin/apxs && \
	make && \
	make install

COPY ./apache-saml/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./apache-saml/mellon.conf /usr/local/apache2/conf/mellon.conf
COPY ./apache-saml/idp-metadata.xml /usr/local/apache2/conf/idp-metadata.xml

COPY ./apache-saml/apache_saml.cert /usr/local/apache2/mellon/apache_saml.cert
COPY ./apache-saml/apache_saml.key /usr/local/apache2/mellon/apache_saml.key
COPY ./apache-saml/apache_saml.xml /usr/local/apache2/mellon/apache_saml.xml

