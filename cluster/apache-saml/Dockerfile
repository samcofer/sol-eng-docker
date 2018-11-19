FROM httpd:2.4

# install system deps
	#pkg-config \
RUN apt-get update && \
	apt-get install -y \
	autoconf \
	gcc \
	gdebi \
	autotools-dev \
	pkgconf \
	wget \
	libcurl4-gnutls-dev && \
	wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
    && gdebi -n libssl1.0.0.deb

RUN apt-get install -y \
	libssl-dev \
	libxmlsec1-dev \
	make \
	liblasso3-dev

# build and install mod_auth_mellon
RUN cd /usr/src && \
	wget https://github.com/Uninett/mod_auth_mellon/archive/v0.14.0.tar.gz && \
	tar -xzvf v0.14.0.tar.gz && \
	cd mod_auth_mellon-0.14.0 && \
	aclocal && \
	autoreconf && \
	autoconf && \
	./configure --with-apxs2=/usr/local/apache2/bin/apxs && \
	make && \
	make install

COPY ./apache-saml/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./apache-saml/mellon.conf /usr/local/apache2/conf/mellon.conf
COPY ./apache-saml/idp-metadata.xml /usr/local/apache2/conf/idp-metadata.xml

COPY ./apache-saml/apache_saml.cert /usr/local/apache2/mellon/apache_saml.cert
COPY ./apache-saml/apache_saml.key /usr/local/apache2/mellon/apache_saml.key
COPY ./apache-saml/apache_saml.xml /usr/local/apache2/mellon/apache_saml.xml

# install tools for SSL (if needed)
RUN apt-get install -y curl jq

COPY ./ssl/cert_get.sh /usr/local/apache2/cert_get.sh
COPY ./apache-saml/cert_config.json /usr/local/apache2/cert_config.json
