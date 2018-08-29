FROM httpd:2.4
COPY ./apache-simple.conf /usr/local/apache2/conf/httpd.conf

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


	

	




