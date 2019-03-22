# https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/devel/Dockerfile
# https://www.rstudio.com/products/rstudio/download-commercial/ 
FROM ubuntu:xenial

ARG RSTUDIO_VERSION
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

ENV RSP_LICENSE=$RSP_LICENSE 

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    file \
    gcc \
    gdebi \
    git \
    g++ \
    libapparmor1 \
    libblas3 \
    libcurl4-openssl-dev \
    libedit2 \
    liblapack3 \
    libssl-dev \
    libxt6 \
    lsb-release \
    make \
    psmisc \
    python-setuptools \
    rrdtool \
    sudo \
    wget
# gcc & g++ are only needed as build dependencies for packages

# install R
ARG R_VERSION=3.5.1
RUN mkdir -p /opt/R && \
	curl https://cdn.rstudio.com/r/ubuntu-1604/R-${R_VERSION}-ubuntu-1604.tar.gz | \
	tar xzvf - -C /opt/R/

## Download and install RStudio Server Pro
## Attempts to detect latest version, otherwise falls back to version given in $VER
RUN RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && wget -q https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  #&& wget -q http://download2.rstudio.org/rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-pro-${RSTUDIO_VERSION}-amd64.deb \
  ## use more robust file locking to avoid errors when using shared volumes:
  && echo 'lock-type=advisory' >> /etc/rstudio/file-locks

# add dumb-init init system
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
  && chmod +x /usr/local/bin/dumb-init

COPY base-rsp/rserver.conf /etc/rstudio/rserver.conf

COPY users /tmp/users
RUN awk ' { system("useradd -m -s /bin/bash "$1" && echo "$1":"$2" | chpasswd") } ' /tmp/users && \
	rm /tmp/users

COPY ./base-rsp/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/docker-entrypoint.sh"]
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]

EXPOSE 8787

