FROM rstudio/r-session:trusty-1.2.1070-1

ARG R_VERSION=3.5.1

RUN set -x && \
	apt-get update && \
	apt-get install -y \
	libxml2-dev \
	curl \
	git

# R dependencies
RUN apt-get build-dep -y r-base

# Build $R_VERSION from source
RUN mkdir -p /opt/R && cd /opt/R \
    && wget https://cran.r-project.org/src/base/R-3/R-$R_VERSION.tar.gz \
    && tar zxvf R-$R_VERSION.tar.gz \
    && cd R-$R_VERSION  \
    && ./configure --prefix=/opt/R/$R_VERSION --enable-R-shlib \
    && make \
    && make install

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
